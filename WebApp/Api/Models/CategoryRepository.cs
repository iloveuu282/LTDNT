using System.Data;
using Dapper;
namespace WebApp.Api.Models;
public class CategoryRepository : BaseRepository
{
    public CategoryRepository(IDbConnection connection) : base(connection)
    {
    }
    public IEnumerable<Category> GetCategories()
    {
        return connection.Query<Category>("SELECT * FROM Category ORDER BY CategoryId");
    }
    public int Add(Category obj)
    {
        string sql = "INSERT INTO Category (CategoryId, CategoryName, Title, Description, Icon) VALUES (@CategoryId, @CategoryName, @Title, @Description, @Icon)";
        return connection.Execute(sql, obj);
    }

    public Category? GetCategory(short id)
    {
        string sql = "SELECT * FROM Category WHERE CategoryId = @Id";
        return connection.QuerySingleOrDefault<Category>(sql, new { Id = id });
    }

    public int Edit(Category obj)
    {
        string sql = "UPDATE Category SET CategoryName = @CategoryName, Title = @Title, Description = @Description, Icon = @Icon WHERE CategoryId = @CategoryId";
        return connection.Execute(sql, obj);
    }
    public int Delete(short id)
    {
        return connection.QuerySingle<int>("DeleteCategory", new { id },
            commandType: CommandType.StoredProcedure);
    }
}
