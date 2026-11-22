using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SurveyApi.Api.Models;
using SurveyApi.Services;

namespace SurveyApi.Api.Controllers;

[ApiController,Route("api/surveys"),Authorize]
public class SurveyController(SiteProvider provider,ImageService images):ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> Get(int page=1,int pageSize=10,int? categoryId=null,string? search=null)
    {
        if(page<1 || page>100000 || pageSize<1 || pageSize>50 || (search?.Length??0)>150) return BadRequest(new {message="Tham số phân trang/tìm kiếm không hợp lệ."});
        return Ok(await provider.Survey.GetPage(page,pageSize,categoryId,search));
    }
    [HttpGet("{id:int}")] public async Task<IActionResult> Details(int id)
    {
        var survey=await provider.Survey.Find(id);
        return survey is null?NotFound():Ok(survey);
    }
    [HttpGet("{id:int}/related")]
    public async Task<IActionResult> Related(int id,int page=1,int pageSize=10)
    {
        if(page<1 || page>100000 || pageSize<1 || pageSize>50) return BadRequest();
        var survey=await provider.Survey.Find(id);
        if(survey is null) return NotFound();
        return Ok(await provider.Survey.Related(id,survey.CategoryId,page,pageSize));
    }
    [HttpPost,Authorize(Roles="Admin"),RequestSizeLimit(6000000)]
    public async Task<IActionResult> Add([FromForm] SurveyForm form)
    {
        string? path=null;
        try
        {
            SurveyRules.ValidateQuestions(form);
            if(form.Image is null) return BadRequest(new {message="Phải chọn ảnh khi thêm mẫu khảo sát."});
            path=await images.Save(form.Image);
            var id=await provider.Survey.Add(form,path);
            path=null;
            return StatusCode(201,new {surveyId=id});
        }
        catch(ArgumentException ex) { return BadRequest(new {message=ex.Message}); }
        catch(SqlException ex) when(ex.Number==547) { return BadRequest(new {message="Danh mục không tồn tại."}); }
        finally { images.Delete(path); }
    }
    [HttpPut("{id:int}"),Authorize(Roles="Admin"),RequestSizeLimit(6000000)]
    public async Task<IActionResult> Update(int id,[FromForm] SurveyForm form)
    {
        string? path=null;
        try
        {
            SurveyRules.ValidateQuestions(form);
            if(form.Image is not null) path=await images.Save(form.Image);
            var old=await provider.Survey.Update(id,form,path);
            path=null;
            images.Delete(old);
            return Ok(new {message="Đã cập nhật mẫu khảo sát."});
        }
        catch(ArgumentException ex) {return BadRequest(new {message=ex.Message});}
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(InvalidOperationException ex) {return Conflict(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number==547) {return BadRequest(new {message="Danh mục không tồn tại."});}
        finally {images.Delete(path);}
    }
    [HttpDelete("{id:int}"),Authorize(Roles="Admin")]
    public async Task<IActionResult> Delete(int id)
    {
        try { images.Delete(await provider.Survey.Delete(id)); return Ok(new {message="Đã xóa mẫu và ảnh."}); }
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(InvalidOperationException ex) {return Conflict(new {message=ex.Message});}
    }
}
