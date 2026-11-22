using System.Data;
using Dapper;

namespace WebApp.Api.Models;

public class StatusRepository : BaseRepository
{
    public StatusRepository(IDbConnection connection) : base(connection)
    {
    }

    public IEnumerable<Status> GetStatuses() => connection.Query<Status>("SELECT * FROM Status");
}
