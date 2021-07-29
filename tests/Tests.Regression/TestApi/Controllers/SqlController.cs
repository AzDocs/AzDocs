using System.Collections.Generic;
using System.Data.SqlClient;
using Azure.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SqlController : ControllerBase
    {
        private readonly ILogger<SqlController> _logger;
        private IConfiguration Configuration { get; }

        public SqlController(ILogger<SqlController> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }

        [HttpGet]
        public IEnumerable<string> Get()
        {
            using (SqlConnection connection = new SqlConnection(Configuration.GetConnectionString("SqlConnectionString")))
            {
                var credential = new DefaultAzureCredential();
                var token = credential
                    .GetToken(new Azure.Core.TokenRequestContext(
                        new[] { "https://database.windows.net/.default" }));
                connection.AccessToken = token.Token;
                connection.Open();

                SqlCommand createCommand = new SqlCommand("" +
                                                    "IF NOT EXISTS(SELECT [name] FROM sys.tables WHERE [name] = 'TestTable') " +
                                                    "BEGIN " +
                                                    "CREATE TABLE [dbo].[TestTable]([Id][int] IDENTITY(1, 1) NOT NULL,[Message][nvarchar](250) NOT NULL) ON[PRIMARY] " +
                                                    "INSERT INTO [dbo].[TestTable]([Message])VALUES('This is a test') " +
                                                    "INSERT INTO [dbo].[TestTable]([Message])VALUES('This is the second test') " +
                                                    "END", connection);
                createCommand.ExecuteNonQuery();

                List<string> messages = new List<string>();
                SqlCommand command = new SqlCommand("SELECT * FROM [dbo].[TestTable]", connection);
                using (SqlDataReader reader = command.ExecuteReader())
                    while (reader.Read())
                        messages.Add(reader["Message"].ToString());
                return messages;
            }
        }
    }
}
