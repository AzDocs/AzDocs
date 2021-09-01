using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Files.Shares;
using Azure.Storage.Queues;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class StorageController : ControllerBase
    {
        private readonly ILogger<StorageController> _logger;
        private IConfiguration _configuration;

        public StorageController(ILogger<StorageController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        /// <summary>
        /// Returns the content of a blob container in a Storage Account.
        /// </summary>
        /// <returns>A string response.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /storage/blob
        ///
        /// </remarks>
        /// <response code="200">Returns the content of a blob container.</response>
        [HttpGet]
        [Route("blob")]
        public string GetBlob()
        {
            var storageUrl =
                new Uri($"https://{Environment.GetEnvironmentVariable("StorageAccount")}.blob.core.windows.net");
            var storageClient = new BlobServiceClient(storageUrl, new DefaultAzureCredential());

            var containerClient = storageClient.GetBlobContainerClient("myblobcontainer");
            var blobClient = containerClient.GetBlobClient("test.txt");
            var reader = new StreamReader(blobClient.Download().Value.Content);
            var fileContent = reader.ReadToEnd();

            return $"This file is part of the blob container: {fileContent}";
        }

        /// <summary>
        /// Returns the content of a message in a queue in a Storage Account.
        /// </summary>
        /// <returns>A string response.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /storage/queue
        ///
        /// </remarks>
        /// <response code="200">Returns the content of a message in the queue.</response>
        [HttpGet]
        [Route("queue")]
        public async Task<string> GetQueue()
        {
            var queueUrl =
                new Uri(
                    $"https://{Environment.GetEnvironmentVariable("StorageAccount")}.queue.core.windows.net/{Environment.GetEnvironmentVariable("QueueName")}");
            var queueClient = new QueueClient(queueUrl, new DefaultAzureCredential());

            try
            {
                var message = await queueClient.ReceiveMessageAsync();
                if (message != null)
                {
                    return $"This is a message from the queue: {message.Value.MessageText}";
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error while getting message from the queue", ex);
            }

            return "There are no messages on the queue available. Run the /queue/add first.";
        }

        /// <summary>
        /// Adds a message in a queue of a storage account.
        /// </summary>
        /// <returns>A string response.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /storage/queue/add
        ///
        /// </remarks>
        /// <response code="200">Message is added in the queue.</response>
        [HttpGet]
        [Route("queue/add")]
        public async Task<string> AddToQueue()
        {
            var queueUrl =
                new Uri(
                    $"https://{Environment.GetEnvironmentVariable("StorageAccount")}.queue.core.windows.net/{Environment.GetEnvironmentVariable("QueueName")}");
            var queueClient = new QueueClient(queueUrl, new DefaultAzureCredential());
            var queueMessage = "This is a test message";

            try
            {
                await queueClient.SendMessageAsync(queueMessage);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error while sending message to queue", ex.Message);
                return
                    $"Something went wrong while adding message to queue {Environment.GetEnvironmentVariable("QueueName")}";
            }

            return $"Added message to queue {Environment.GetEnvironmentVariable("QueueName")}";
        }

        /// <summary>
        /// Returns the content of a file in a fileshare of a storage account.
        /// </summary>
        /// <returns>
        /// A string response.
        /// </returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /storage/fileshare
        ///
        /// </remarks>
        /// <response code="200">Returns the content of the file in the fileshare.</response>
        /// <response code="500">Returns 500 if it is unable to perform the request.</response>
        [HttpGet]
        [Route("fileshare")]
        public async Task<string> GetFileshare()
        {
            // this resource does not have support for managed identities, see https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities
            var fileName = "test.txt";
            var storageConnectionString = _configuration.GetConnectionString("StorageConnectionString");
            var shareClient = new ShareClient(storageConnectionString, Environment.GetEnvironmentVariable("FileShareName"));

            if (await shareClient.ExistsAsync())
            {
                // getting file from root
                var directory = shareClient.GetRootDirectoryClient();
                if (await directory.ExistsAsync())
                {
                    var fileClient = directory.GetFileClient(fileName);
                    if (!await fileClient.ExistsAsync())
                    {
                        await UploadFile(fileClient, fileName);
                    }

                    var result = await ReadFileFromFileShare(fileClient, fileName);
                    return !string.IsNullOrEmpty(result) ? result : "Something went wrong. Check the logs for more information.";
                }
            }

            return "The fileshare does not exist.";
        }

        private async Task<string> ReadFileFromFileShare(ShareFileClient fileClient, string fileName)
        {
            var download = await fileClient.DownloadAsync();
            using StreamReader reader = new StreamReader(download.Value.Content);
            var result = await reader.ReadToEndAsync();
            return result;
        }

        private async Task UploadFile(ShareFileClient fileClient, string fileName)
        {
            try
            {
                // read contents from assembly and upload to new file
                var assembly = Assembly.GetExecutingAssembly();
                var resourceName = assembly.GetManifestResourceNames().Single(str => str.EndsWith(fileName));

                using Stream stream = assembly.GetManifestResourceStream(resourceName);
                using StreamReader reader = new StreamReader(stream);

                await fileClient.CreateAsync(stream.Length);
                await fileClient.UploadAsync(stream);
            }
            catch (Exception ex)
            {
                _logger.LogError("The upload of the file to the fileshare failed.", ex);
            }
        }
    }
}