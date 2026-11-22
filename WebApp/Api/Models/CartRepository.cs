using System.Data;
using Dapper;

namespace WebApp.Api.Models;

public class CartRepository : BaseRepository
{
    public CartRepository(IDbConnection connection) : base(connection) { }

    public int Add(Cart obj)
    {
        connection.Execute("AddCart", obj, commandType: CommandType.StoredProcedure);
        return 1;
    }

    public IEnumerable<CartEx> GetCarts(string memberId)
    {
        string sql = "SELECT Cart.*, BikeName, Price, ImageUrl FROM Cart JOIN Bike ON Cart.BikeId = Bike.BikeId AND MemberId = @MemberId";
        return connection.Query<CartEx>(sql, new { memberId });
    }

    public int Delete(int bikeId, string memberId)
    {
        string sql = "DELETE FROM Cart WHERE BikeId = @BikeId AND MemberId = @MemberId";
        return connection.Execute(sql, new { bikeId, memberId });
    }
}
