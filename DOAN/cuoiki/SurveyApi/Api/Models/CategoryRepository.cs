using System.Data;
using Dapper;

namespace SurveyApi.Api.Models;

public class CategoryRepository(IDbConnection connection) : BaseRepository(connection)
{
    public Task<IEnumerable<Category>> GetAll() => connection.QueryAsync<Category>("SELECT * FROM Categories ORDER BY CategoryId");
    public Task<int> Add(CategoryForm model,string? imagePath) => connection.QuerySingleAsync<int>(
        "INSERT INTO Categories(CategoryName,Description,ImagePath) OUTPUT INSERTED.CategoryId VALUES(@name,@description,@imagePath)",
        new { name=model.CategoryName.Trim(), description=model.Description?.Trim(),imagePath });

    public async Task<string?> Update(int id,CategoryForm model,string? newImage)
    {
        if(connection.State!=ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var current=await connection.QuerySingleOrDefaultAsync<Category>(
            "SELECT * FROM Categories WITH (UPDLOCK,HOLDLOCK) WHERE CategoryId=@id",new { id },tx);
        if(current is null) throw new KeyNotFoundException("Không tìm thấy danh mục.");
        var image=model.RemoveImage?null:newImage??current.ImagePath;
        await connection.ExecuteAsync("UPDATE Categories SET CategoryName=@name,Description=@description,ImagePath=@image WHERE CategoryId=@id",
            new { id,name=model.CategoryName.Trim(),description=model.Description?.Trim(),image },tx);
        tx.Commit();
        return model.RemoveImage || newImage is not null?current.ImagePath:null;
    }

    public async Task<string?> Delete(int id)
    {
        if(connection.State!=ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var current=await connection.QuerySingleOrDefaultAsync<Category>(
            "SELECT * FROM Categories WITH (UPDLOCK,HOLDLOCK) WHERE CategoryId=@id",new { id },tx);
        if(current is null) throw new KeyNotFoundException("Không tìm thấy danh mục.");
        // FK chặn xóa danh mục có mẫu, kể cả khi nhiều yêu cầu chạy đồng thời.
        await connection.ExecuteAsync("DELETE FROM Categories WHERE CategoryId=@id",new { id },tx);
        tx.Commit();
        return current.ImagePath;
    }
}
