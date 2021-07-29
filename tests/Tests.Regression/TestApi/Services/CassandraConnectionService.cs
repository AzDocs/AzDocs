using System;
using System.Net.Security;
using System.Security.Authentication;
using System.Security.Cryptography.X509Certificates;
using Cassandra;
using Microsoft.Extensions.Logging;

namespace TestApi.Services
{
    public class CassandraConnectionService : ICassandraConnectionService
    {
        private ISession _cassandraSession;
        private static ILogger<CassandraConnectionService> _logger;
        private const int _cassandraPort = 10350;

        public CassandraConnectionService(ILogger<CassandraConnectionService> logger)
        {
            _logger = logger;
        }

        // for more keyspaces it is recommended to create a session per keyspace (to a certain extent). For this test, this has not been added.
        public ISession GetCassandraSession()
        {
            if (_cassandraSession == null)
            {
                // Connect to cassandra cluster  (Cassandra API on Azure Cosmos DB supports only TLSv1.2)
                var options = new SSLOptions(SslProtocols.Tls12, true, ValidateServerCertificate);
                options.SetHostNameResolver((ipAddress) => Environment.GetEnvironmentVariable("CassandraContactPoint"));

                Cluster cluster = Cluster
                    .Builder()
                    .WithCredentials(Environment.GetEnvironmentVariable("CassandraUser"),
                        Environment.GetEnvironmentVariable("CassandraPassword"))
                    .WithPort(_cassandraPort)
                    .AddContactPoint(Environment.GetEnvironmentVariable("CassandraContactPoint"))
                    .WithSSL(options)
                    .Build();

                _logger.LogInformation("Setting up session to cassandra cosmosdb.");
                _cassandraSession = cluster.Connect();
            }

            return _cassandraSession;
        }

        private static bool ValidateServerCertificate(
            object sender,
            X509Certificate certificate,
            X509Chain chain,
            SslPolicyErrors sslPolicyErrors)
        {
            if (sslPolicyErrors == SslPolicyErrors.None)
                return true;

            _logger.LogInformation("Certificate error: {0}", sslPolicyErrors);
            // Do not allow this client to communicate with unauthenticated servers.
            return false;
        }
    }
}
