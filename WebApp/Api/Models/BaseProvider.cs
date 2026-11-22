using System.Data;
using Microsoft.Data.SqlClient;
namespace WebApp.Api.Models;
public abstract class BaseProvider : IDisposable
{
    private IDbConnection? connection;
    private readonly IConfiguration configuration;
    protected BaseProvider(IConfiguration configuration)
    {
        this.configuration = configuration;
    }
    protected IDbConnection Connection => connection ??= new SqlConnection(
        configuration.GetConnectionString("TrekBikes")
        ?? throw new InvalidOperationException("Thiếu ConnectionStrings:TrekBikes."));

    public void Dispose()
    {
        connection?.Dispose();
        GC.SuppressFinalize(this);
    }
}
