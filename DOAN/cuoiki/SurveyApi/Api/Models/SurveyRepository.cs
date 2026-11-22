using System.Data;
using Dapper;

namespace SurveyApi.Api.Models;

public class SurveyRepository(IDbConnection connection) : BaseRepository(connection)
{
    private const string SelectSql = """
        SELECT s.*, c.CategoryName,
          CAST(CASE WHEN EXISTS(SELECT 1 FROM CampaignItems i WHERE i.SurveyId=s.SurveyId) THEN 1 ELSE 0 END AS BIT) AS IsUsed
        FROM Surveys s JOIN Categories c ON s.CategoryId=c.CategoryId
        """;

    public async Task<PageResult<Survey>> GetPage(int page, int size, int? categoryId, string? search)
    {
        var args = new { categoryId, search = "%" + (search ?? "").Trim() + "%", skip=(page-1)*size, size };
        const string where = " WHERE (@categoryId IS NULL OR s.CategoryId=@categoryId) AND s.Title LIKE @search";
        var total = await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Surveys s"+where, args);
        var items = await connection.QueryAsync<Survey>(SelectSql+where+" ORDER BY s.SurveyId DESC OFFSET @skip ROWS FETCH NEXT @size ROWS ONLY", args);
        return new(items, total, page, size);
    }

    public Task<Survey?> Find(int id) => connection.QuerySingleOrDefaultAsync<Survey>(SelectSql+" WHERE s.SurveyId=@id", new { id });

    public async Task<PageResult<Survey>> Related(int id,int categoryId,int page,int size)
    {
        const string where=" WHERE s.CategoryId=@categoryId AND s.SurveyId<>@id";
        var args=new { id,categoryId,skip=(page-1)*size,size };
        var total=await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Surveys s"+where,args);
        var items=await connection.QueryAsync<Survey>(SelectSql+where+" ORDER BY s.SurveyId DESC OFFSET @skip ROWS FETCH NEXT @size ROWS ONLY",args);
        return new(items,total,page,size);
    }

    public Task<int> Add(SurveyForm form, string imagePath) => connection.QuerySingleAsync<int>(
        """
        INSERT INTO Surveys(CategoryId,Title,Description,ImagePath,QuestionsJson)
        OUTPUT INSERTED.SurveyId VALUES(@CategoryId,@title,@description,@imagePath,@QuestionsJson)
        """, new { form.CategoryId, title=form.Title.Trim(), description=form.Description.Trim(), imagePath, form.QuestionsJson });

    public async Task<string?> Update(int id, SurveyForm form, string? newImage)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var transaction = connection.BeginTransaction(IsolationLevel.Serializable);
        var current = await connection.QuerySingleOrDefaultAsync<Survey>("SELECT * FROM Surveys WITH (UPDLOCK,HOLDLOCK) WHERE SurveyId=@id", new { id }, transaction);
        if (current is null) throw new KeyNotFoundException("Không tìm thấy mẫu khảo sát.");
        if (await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM CampaignItems WHERE SurveyId=@id", new { id }, transaction)>0)
            throw new InvalidOperationException("Mẫu đã có trong chiến dịch, không được sửa. Hãy tạo mẫu mới.");
        await connection.ExecuteAsync("""
            UPDATE Surveys SET CategoryId=@CategoryId,Title=@title,Description=@description,
                QuestionsJson=@QuestionsJson,ImagePath=@image WHERE SurveyId=@id
            """, new { id, form.CategoryId, title=form.Title.Trim(), description=form.Description.Trim(), form.QuestionsJson, image=newImage??current.ImagePath }, transaction);
        transaction.Commit();
        return newImage is null ? null : current.ImagePath;
    }

    public async Task<string> Delete(int id)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var transaction = connection.BeginTransaction(IsolationLevel.Serializable);
        var path = await connection.QuerySingleOrDefaultAsync<string>("SELECT ImagePath FROM Surveys WITH (UPDLOCK,HOLDLOCK) WHERE SurveyId=@id",new { id },transaction);
        if (path is null) throw new KeyNotFoundException("Không tìm thấy mẫu khảo sát.");
        if (await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM CampaignItems WHERE SurveyId=@id",new { id },transaction)>0)
            throw new InvalidOperationException("Mẫu đã có trong chiến dịch, không được xóa.");
        await connection.ExecuteAsync("DELETE FROM PlanItems WHERE SurveyId=@id; DELETE FROM Surveys WHERE SurveyId=@id",new { id },transaction);
        transaction.Commit();
        return path;
    }
}
