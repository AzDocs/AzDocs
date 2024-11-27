using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Text;
using System.IO;

namespace TestApi.Functions
{
    public static class RequestResponseFunction
    {
        [FunctionName("http-request-response-function")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("==Headers==");
            foreach (var header in req.Headers)
            {
                sb.AppendLine($"key: {header.Key}, value: {header.Value}");
            }
            sb.AppendLine("==Headers==");
            sb.AppendLine();
            sb.AppendLine("==Body==");
            try
            {
                using (Stream Body = req.Body)
                {
                    byte[] result;
                    result = new byte[req.Body.Length];
                    await req.Body.ReadAsync(result, 0, (int)req.Body.Length);

                    var body = Encoding.UTF8.GetString(result).TrimEnd('\0');

                    sb.AppendLine(body);
                }
            }
            catch (System.Exception)
            {

                sb.AppendLine("could not parse body");
            }
            sb.AppendLine("==Body==");
            sb.AppendLine();
            sb.AppendLine("==Query==");
            sb.AppendLine(req.QueryString.Value);
            sb.AppendLine("==Query==");
            sb.AppendLine();

            sb.AppendLine("==Path==");
            sb.AppendLine(req.Path.Value);
            sb.AppendLine("==Path==");
            sb.AppendLine();
            sb.AppendLine("==Method==");
            sb.AppendLine(req.Method);
            sb.AppendLine("==Method==");

            log.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult(sb.ToString());
        }
    }
}
