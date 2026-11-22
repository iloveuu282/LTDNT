using System.Data;

namespace SurveyApi.Api.Models;

public abstract class BaseRepository(IDbConnection connection)
{
    protected readonly IDbConnection connection = connection;
}
