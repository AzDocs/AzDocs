using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RedisController : ControllerBase
    {
        private readonly ILogger<RedisController> _logger;

        private readonly IDistributedCache _cache;

        public RedisController(ILogger<RedisController> logger, IDistributedCache cache)
        {
            _logger = logger;
            _cache = cache;
        }

        [HttpGet]
        public async Task<string> Get()
        {
            // for testing purposes the values are hardcoded
            var key = "redisKey";
            var value = await GetRedisValue(key);
            if (value != null)
            {
                return value;
            }

            await SetRedisValue(key, GetFakeValue());
            return await GetRedisValue(key);
        }

        private string GetFakeValue()
        {
            return DateTime.UtcNow.ToString();
        }

        private async Task<string> GetRedisValue(string redisKey)
        {
            var key = await _cache.GetAsync(redisKey);
            if (key != null)
            {
                _logger.LogInformation($"Found key in RedisCache {key}");

                using var memoryStream = new MemoryStream(key);
                var keyValue = await JsonSerializer.DeserializeAsync<string>(memoryStream);
                return keyValue;
            }

            return null;
        }

        private async Task SetRedisValue(string redisKey, string redisValue)
        {
            // for testing purposes, this has the AbsoluteExpirationRelativeToNow set to 5 seconds hardcoded
            var value = JsonSerializer.SerializeToUtf8Bytes(redisValue);
            await _cache.SetAsync(redisKey, value, new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(5) });
        }
    }
}
