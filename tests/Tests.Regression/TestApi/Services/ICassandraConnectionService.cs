using Cassandra;

namespace TestApi.Services
{
    public interface ICassandraConnectionService
    {
        ISession GetCassandraSession();
    }
}