using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SurveyApi.Api.Models;
using SurveyApi.Services;

namespace SurveyApi.Api.Controllers;

[ApiController,Route("api/categories"),Authorize]
public class CategoryController(SiteProvider provider,ImageService images):ControllerBase
{
    [HttpGet] public async Task<IActionResult> Get()=>Ok(await provider.Category.GetAll());
    [HttpPost,Authorize(Roles="Admin"),RequestSizeLimit(6000000)]
    public async Task<IActionResult> Add([FromForm] CategoryForm model)
    {
        if(model.CategoryName.Trim().Length<2) return BadRequest(new {message="Tên danh mục ít nhất 2 ký tự."});
        string? path=null;
        try
        {
            if(model.Image is not null) path=await images.Save(model.Image);
            var id=await provider.Category.Add(model,path);
            path=null;
            return StatusCode(201,new {categoryId=id});
        }
        catch(ArgumentException ex) {return BadRequest(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number is 2601 or 2627) {return Conflict(new {message="Tên danh mục đã tồn tại."});}
        finally {images.Delete(path);}
    }
    [HttpPut("{id:int}"),Authorize(Roles="Admin"),RequestSizeLimit(6000000)]
    public async Task<IActionResult> Update(int id,[FromForm] CategoryForm model)
    {
        if(model.CategoryName.Trim().Length<2 || (model.RemoveImage && model.Image is not null))
            return BadRequest(new {message="Tên ít nhất 2 ký tự. Không đồng thời thay và xóa ảnh."});
        string? path=null;
        try
        {
            if(model.Image is not null) path=await images.Save(model.Image);
            var old=await provider.Category.Update(id,model,path);
            path=null;
            images.Delete(old);
            return Ok(new {message="Đã cập nhật danh mục."});
        }
        catch(ArgumentException ex) {return BadRequest(new {message=ex.Message});}
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number is 2601 or 2627) {return Conflict(new {message="Tên danh mục đã tồn tại."});}
        finally {images.Delete(path);}
    }
    [HttpDelete("{id:int}"),Authorize(Roles="Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        try {images.Delete(await provider.Category.Delete(id));return Ok(new {message="Đã xóa danh mục và ảnh đại diện."});}
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number==547) {return Conflict(new {message="Danh mục còn mẫu khảo sát, không được xóa."});}
    }
}
