using System;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Security.KeyVault.Keys;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class KeyVaultController : ControllerBase
    {
        private readonly ILogger<KeyVaultController> _logger;
        private readonly string _keyVaultName = Environment.GetEnvironmentVariable("KeyvaultName");

        public KeyVaultController(ILogger<KeyVaultController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<string> Get()
        {
            var keyvaultKeyName = Environment.GetEnvironmentVariable("KeyvaultKey");
            var keyClient = new KeyClient(new Uri($"https://{_keyVaultName}.vault.azure.net/"), new DefaultAzureCredential());
            var key = await keyClient.GetKeyAsync(keyvaultKeyName);

            if (key?.Value == null)
            {
                _logger.LogInformation($"Could not find key {keyvaultKeyName}");
                return null;
            }

            _logger.LogInformation($"Found key with name {key.Value.Name}");
            return $"Returning the key with name {key.Value.Name} and the key was created on: {key.Value.Properties.CreatedOn}";
        }

        [Route("secret")]
        [HttpGet]
        public async Task<string> GetSecret()
        {
            var keyvaultSecretName = Environment.GetEnvironmentVariable("KeyvaultSecret");
            var secretClient = new SecretClient(new Uri($"https://{_keyVaultName}.vault.azure.net/"), new DefaultAzureCredential());
            var secret = await secretClient.GetSecretAsync(keyvaultSecretName);

            if (secret?.Value == null)
            {
                _logger.LogInformation($"Could not find secret with name {keyvaultSecretName}");
                return null;
            }

            _logger.LogInformation($"Found secret with {secret.Value.Name}");
            return $"Returning the secret with name {secret.Value.Name} and value: {secret.Value.Value}";
        }
    }
}
