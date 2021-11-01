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
        public async Task<string> GetBlob()
        {
            var storageUrl = new Uri($"https://{Environment.GetEnvironmentVariable("StorageAccount")}.blob.core.windows.net");
            var storageClient = new BlobServiceClient(storageUrl, new DefaultAzureCredential());
            var containerClient = storageClient.GetBlobContainerClient($"{Environment.GetEnvironmentVariable("BlobContainer")}");
            
            string blobName = "test.txt";
            BlobClient blobClient = containerClient.GetBlobClient(blobName); // Get a reference to a blob

            try
            {
                // read contents from assembly and upload to new file
                var assembly = Assembly.GetExecutingAssembly();
                var resourceName = assembly.GetManifestResourceNames().Single(str => str.EndsWith(blobName));
                using Stream stream = assembly.GetManifestResourceStream(resourceName);
                
                await blobClient.UploadAsync(stream, true);
            }
            catch (Exception ex)
            {
                _logger.LogError("The upload of the file to blob failed.", ex);
            }

            var blob = await blobClient.DownloadContentAsync();
            return blob.Value.Content.ToString();
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
            var queueUrl = new Uri($"https://{Environment.GetEnvironmentVariable("StorageAccount")}.queue.core.windows.net/{Environment.GetEnvironmentVariable("QueueName")}");
            var queueClient = new QueueClient(queueUrl, new DefaultAzureCredential());
            var queueMessage = "This is a test message";

            try
            {
                // first send a message on the queue
                await queueClient.SendMessageAsync(queueMessage);

                // get message from the queue
                var message = await queueClient.ReceiveMessageAsync();
                if (message != null)
                    return $"This is a message from the queue: {message.Value.MessageText}";
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error while getting message from the queue with Message {ex.Message} and StackTrace: {ex.StackTrace}");
                return "Something went wrong.";
            }

            return "No messages were found and no messages were inserted.";
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