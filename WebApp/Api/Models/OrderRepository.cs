using System.Data;
using Dapper;

namespace WebApp.Api.Models;

public class OrderRepository : BaseRepository
{
    public OrderRepository(IDbConnection connection) : base(connection)
    {
    }

    public int UpdateStatus(long id, short statusId)
    {
        string sql = "UPDATE [Order] SET StatusId = @StatusId WHERE OrderId = @Id";
        return connection.Execute(sql, new { id, statusId });
    }

    public IEnumerable<Order> GetOrders(string memberId)
    {
        string sql = "SELECT [Order].*, StatusName FROM [Order] JOIN Status ON [Order].StatusId = Status.StatusId WHERE MemberId = @MemberId";
        return connection.Query<Order>(sql, new { memberId });
    }

    public int Add(Order obj)
    {
        return connection.Execute("AddOrder", new { obj.MemberId, obj.StatusId, obj.OrderId }, commandType: CommandType.StoredProcedure);
    }
}
