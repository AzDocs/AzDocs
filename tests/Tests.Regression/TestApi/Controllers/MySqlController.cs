using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MySql.Data.MySqlClient;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class MySqlController : ControllerBase
    {
        private readonly ILogger<MySqlController> _logger;
        private IConfiguration Configuration { get; }

        public MySqlController(ILogger<MySqlController> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }
        /// <summary>
        /// Returns numbers from the configured table in the MySQL database. Table is created if it does not exist. Numbers are inserted automatically.
        /// </summary>
        /// <returns>A string response.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /mysql
        ///
        /// </remarks>
        /// <response code="200">Returns the result of a query of a table.</response>
        [HttpGet]
        public IEnumerable<int> Get()
        {
            using (MySqlConnection connection = new MySqlConnection(Configuration.GetConnectionString("MySqlConnectionString")))
            {
                connection.Open();
                using (MySqlCommand command = new MySqlCommand("CREATE TABLE IF NOT EXISTS TestTable(Id INT AUTO_INCREMENT PRIMARY KEY, Number INT NOT NULL) ENGINE=INNODB;", connection))
                {
                    command.ExecuteNonQuery();
                }

                using (MySqlCommand command = new MySqlCommand("INSERT INTO TestTable (Number) VALUES (@number);", connection))
                {
                    command.Parameters.Add(new MySqlParameter("number", new Random().Next()));
                    command.ExecuteNonQuery();
                }

                List<int> nummertjes = new List<int>();
                using (MySqlCommand command = new MySqlCommand("SELECT * FROM `TestTable`;", connection))
                {
                    using (MySqlDataReader reader = command.ExecuteReader())
                        while (reader.Read())
                            nummertjes.Add(int.Parse(reader["Number"].ToString()));
                }

                return nummertjes;
            }
        }
    }
}
