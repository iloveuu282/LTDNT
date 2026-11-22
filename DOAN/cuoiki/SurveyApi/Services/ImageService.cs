namespace SurveyApi.Services;

public class ImageService(IWebHostEnvironment environment)
{
    public async Task<string> Save(IFormFile file)
    {
        if (file.Length is <8 or >5242880) throw new ArgumentException("Ảnh phải nhỏ hơn 5 MB và là PNG hoặc JPEG.");
        var bytes=new byte[8];
        await using (var input=file.OpenReadStream()) await input.ReadExactlyAsync(bytes);
        var png=bytes.SequenceEqual(new byte[]{137,80,78,71,13,10,26,10});
        var jpeg=bytes[0]==255 && bytes[1]==216 && bytes[2]==255;
        if (!png && !jpeg) throw new ArgumentException("Chỉ nhận ảnh PNG hoặc JPEG.");
        var directory=Path.Combine(environment.ContentRootPath,"wwwroot","uploads");
        Directory.CreateDirectory(directory);
        var name=Guid.NewGuid().ToString("N")+(png?".png":".jpg");
        var path=Path.Combine(directory,name);
        try
        {
            await using var output=File.Create(path);
            await file.CopyToAsync(output);
        }
        catch { if(File.Exists(path)) File.Delete(path); throw; }
        return "/uploads/"+name;
    }
    public void Delete(string? imagePath)
    {
        if (string.IsNullOrEmpty(imagePath) || !imagePath.StartsWith("/uploads/")) return;
        var name=Path.GetFileName(imagePath);
        var path=Path.Combine(environment.ContentRootPath,"wwwroot","uploads",name);
        if(File.Exists(path)) File.Delete(path);
    }
}
