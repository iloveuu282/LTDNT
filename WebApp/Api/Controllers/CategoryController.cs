using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using WebApp.Api.Models;
namespace WebApp.Api.Controllers;
[ApiController, Route("api/[controller]")]
public class CategoryController : BaseController
{
    [HttpGet]
    public ActionResult<IEnumerable<Category>> GetCategories()
    {
        return Ok(Provider.Category.GetCategories());
    }
    [HttpGet("{id}")]
    public ActionResult<Category> GetCategory(short id)
    {
        if (id <= 0) return BadRequest("Mã danh mục phải lớn hơn 0.");
        var category = Provider.Category.GetCategory(id);
        return category is null ? NotFound() : Ok(category);
    }
    [HttpPut]
    public ActionResult<int> Edit(Category obj)
    {
        var affected = Provider.Category.Edit(obj);
        return affected == 0 ? NotFound() : Ok(affected);
    }
    [HttpPost]
    public ActionResult<int> Add(Category obj)
    {
        try
        {
            return Ok(Provider.Category.Add(obj));
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)
        {
            return Conflict("Mã danh mục đã tồn tại.");
        }
    }
    [HttpDelete("{id}")]
    public ActionResult<int> Delete(short id)
    {
        if (id <= 0) return BadRequest("Mã danh mục phải lớn hơn 0.");
        var affected = Provider.Category.Delete(id);
        if (affected == -1) return Conflict("Danh mục đang có danh mục con nên không thể xóa.");
        return affected == 0 ? NotFound() : Ok(affected);
    }
}
