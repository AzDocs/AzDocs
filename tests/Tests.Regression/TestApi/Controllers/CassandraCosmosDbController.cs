// THIS HAS BEEN COMMENTED SINCE WE DON'T HAVE SCRIPTS YET THAT PROVIDE A COSMOSDB FOR CASSANDRA

//using System.Collections.Generic;
//using Microsoft.AspNetCore.Mvc;
//using Cassandra;
//using Cassandra.Mapping;
//using Microsoft.Extensions.Logging;
//using TestApi.Models;
//using TestApi.Services;

//namespace TestApi.Controllers
//{
//    [ApiController]
//    [Route("cassandra")]
//    public class CassandraCosmosDbController : ControllerBase
//    {
//        private static ILogger<CassandraCosmosDbController> _logger;
//        private ISession session;
//        private ICassandraConnectionService _cassandraService;

//        public CassandraCosmosDbController(ILogger<CassandraCosmosDbController> logger, ICassandraConnectionService cassandraService)
//        {
//            _logger = logger;
//            _cassandraService = cassandraService;
//        }
//        /// <summary>
//        /// Returns data in a Cassandra keyspace table. The keyspace and table are created if they do not exist.
//        /// </summary>
//        /// <returns>A string status.</returns>
//        /// <remarks>
//        /// Sample request:
//        ///
//        ///     Get /cassandra
//        ///
//        /// </remarks>
//        /// <response code="200">Returns data in a table.</response>
//        [HttpGet]
//        public string Get()
//        {
//            // setup session
//            session = _cassandraService.GetCassandraSession();

//            // create a keyspace
//            CreateKeyspace("users");

//            // change the session to use that keyspace (when creating a session per keyspace, this is not necessary like this)
//            session.ChangeKeyspace("users");

//            // creating table
//            session.Execute("CREATE TABLE IF NOT EXISTS users.user (user_id int PRIMARY KEY, user_name text, user_bcity text)");

//            // checking if there's already some data available
//            IMapper mapper = new Mapper(session);
//            var user = mapper.FirstOrDefault<User>("Select * from user where user_id = ?", 1);
//            if (user == null)
//            {
//                // inserting test data
//                mapper.Insert(new User(1, "LyubovK", "Dubai"));
//                mapper.Insert(new User(2, "JiriK", "Toronto"));
//                mapper.Insert(new User(3, "IvanH", "Mumbai"));
//                mapper.Insert(new User(4, "LiliyaB", "Seattle"));
//                mapper.Insert(new User(5, "JindrichH", "Buenos Aires"));
//            }

//            user = mapper.FirstOrDefault<User>("Select * from user where user_id = ?", 1);
//            return user.user_name;
//        }

//        private void CreateKeyspace(string keyspaceName)
//        {
//            // using SimpleStrategy => which assigns the replication factor the entire cluster (only for dev/test environments)
//            session.CreateKeyspaceIfNotExists(keyspaceName, new Dictionary<string, string> { { "class", "SimpleStrategy" }, { "replication_factor", "1" } });
//        }

//    }
//}
