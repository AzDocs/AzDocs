using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Npgsql;

namespace TestApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PostgreSqlController : ControllerBase
    {
        private IConfiguration Configuration { get; }

        public PostgreSqlController(IConfiguration configuration)
        {
            Configuration = configuration;
        }
        /// <summary>
        /// Returns numbers from a configured table of the PostGreSQL database. The table is created if it does not exist. Random numbers are added automatically.
        /// </summary>
        /// <returns>A string response.</returns>
        /// <remarks>
        /// Sample request:
        ///
        ///     Get /postgresql
        ///
        /// </remarks>
        /// <response code="200">Returns the result of a query.</response>
        [HttpGet]
        public IEnumerable<int> Get()
        {
            // Connect to a PostgreSQL database
            using (NpgsqlConnection connection = new NpgsqlConnection(Configuration.GetConnectionString("PostgreSQLConnectionString")))
            {
                connection.Open();

                using (NpgsqlCommand command = new NpgsqlCommand("CREATE TABLE IF NOT EXISTS TestTable(Id serial PRIMARY KEY, Number integer NOT NULL);", connection))
                {
                    command.ExecuteNonQuery();
                }

                using (NpgsqlCommand command = new NpgsqlCommand("INSERT INTO TestTable (Number) VALUES (@number);", connection))
                {
                    command.Parameters.Add(new NpgsqlParameter("number", new Random().Next()));
                    command.ExecuteNonQuery();
                }

                List<int> nummertjes = new List<int>();
                using (NpgsqlCommand command = new NpgsqlCommand("SELECT * FROM TestTable;", connection))
                {
                    using (NpgsqlDataReader reader = command.ExecuteReader())
                        while (reader.Read())
                            nummertjes.Add(int.Parse(reader["Number"].ToString()));
                }

                return nummertjes;
            }
        }
    }
}
