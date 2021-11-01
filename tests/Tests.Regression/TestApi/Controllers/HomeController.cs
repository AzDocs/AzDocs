using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("")]
    public class HomeController : ControllerBase
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Returns the Home Page, the root of the TestApi.
        /// </summary>
        /// <returns>A string status.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /
        ///
        /// </remarks>
        /// <response code="200">Returns the content of the home page.</response>
        [HttpGet]
        public string Get()
        {
            return "This is the test api, welcome.";
        }
    }
}
