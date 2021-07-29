using NUnit.Framework;
using System.Threading.Tasks;
using Microsoft.Playwright;
using System;
using System.Collections.Generic;
using System.IO;

namespace TestApi.Tests
{
    [TestFixture]
    public class TestApiResourcesTests
    {
        private static bool _enableVideo;
        private static bool _enableScreenshots;

        private static IBrowser _browser;
        private static IBrowserContext _context;
        private static IPage _page;

        private static List<TestResult> _testResults;

        [SetUp]
        public async Task Setup()
        {
            // Arrange before every test
            var webAppUrl = TestContext.Parameters["webAppUrl"];
            _enableVideo = TestContext.Parameters["enableVideo"] != null && bool.Parse(TestContext.Parameters["enableVideo"]);
            _enableScreenshots = TestContext.Parameters["enableScreenshot"] != null && bool.Parse(TestContext.Parameters["enableScreenshot"]);
            _testResults = new List<TestResult>();

            var playwright = await Playwright.CreateAsync();
            var chromium = playwright.Chromium;

            //set options
            _browser = await chromium.LaunchAsync(new BrowserTypeLaunchOptions
            {
                Headless = false,
                Devtools = true,
                SlowMo = 1000
            });

            _context = await _browser.NewContextAsync(new BrowserNewContextOptions
            {
                RecordVideoDir = "videos/",
                BaseURL = webAppUrl
            });

            _page = await _context.NewPageAsync();

            if (_enableVideo)
            {
                var videoPath = await _page.Video.PathAsync();
                _testResults.Add(new TestResult { Description = "videorecording", Path = videoPath });
            }
        }

        [TearDown]
        public async Task Cleanup()
        {
            await _browser.CloseAsync();
            await _context.CloseAsync();

            foreach (var testResult in _testResults)
            {
                TestContext.AddTestAttachment(testResult.Path, testResult.Description);
            }
        }

        [Test]
        [TestCase("textOnHomepage", "")]
        [TestCase("textOnKeyvaultPage", "keyvault")]
        [TestCase("textOnSqlPage", "sql")]
        [TestCase("textOnPostgreSql", "postgresql")]
        [TestCase("textOnMySql", "mysql")]
        [TestCase("textOnRedis", "redis")]
        [TestCase("textOnBlob", "storage/blob")]
        [TestCase("textOnQueue", "storage/queue")]
        [TestCase("textOnFileshare", "storage/fileshare")]
        public static async Task Page_Should_Return_Text(string paramName, string url)
        {
            // because we cannot setup automatic screenshot on failure, we're using (at the moment) this instead. 
            // Todo: investigate if we could better use the tracing option + check how to use this in the test overview in devops
            try
            {
                // Arrange
                string checkTextOnPage = TestContext.Parameters[paramName];

                // Act
                await _page.GotoAsync(url);
                var textContent = await _page.ContentAsync();

                // Assert
                StringAssert.Contains(checkTextOnPage, textContent);
            }
            catch
            {
                if (_enableScreenshots)
                {
                    var screenshotName = $"screenshot_{url}_{DateTime.Now.ToLongDateString()}.png";
                    string screenshotFile = Path.Combine(TestContext.CurrentContext.WorkDirectory, screenshotName);
                    await _page.ScreenshotAsync(new PageScreenshotOptions { Path = screenshotName, FullPage = true });
                    _testResults.Add(new TestResult { Description = screenshotName.Replace(".png", ""), Path = screenshotFile });
                }

                throw;
            }
        }
    }

    public class TestResult
    {
        public string Path { get; set; }
        public string Description { get; set; }
    }

    #region Login

    // If you're using AAD authentication for your application, you can use the following: 
    // Step 1. Add these to your setup and your .runsettings
    // string webAppUsername = TestContext.Parameters["webAppUserName"];
    // string webAppPassword = TestContext.Parameters["webAppPassword"];

    // Step 2. Example for login when visiting the page
    //        if (page.Url.Contains("login.microsoftonline.com"))
    //        {
    //            await page.FillAsync("input[type=\"email\"]", webAppUsername);

    //            // Click text=Next
    //            await page.RunAndWaitForNavigationAsync(async () =>
    //            {
    //                await page.ClickAsync("text=Next");
    //            });

    //            // Fill input[name="passwd"]
    //            await page.FillAsync("input[name=\"passwd\"]", webAppPassword);

    //            // Click text=Sign in
    //            await page.RunAndWaitForNavigationAsync(async () =>
    //            {
    //                await page.ClickAsync("text=Sign in");
    //            });

    //            // Click text=No
    //            await page.RunAndWaitForNavigationAsync(async () =>
    //            {
    //                await page.ClickAsync("text=No");
    //            });

    //            // After Login action we should expect to be on the target Url for performing rest of the tests
    //            Assert.AreEqual(webAppUrl, page.Url);
    //        }
    #endregion

}