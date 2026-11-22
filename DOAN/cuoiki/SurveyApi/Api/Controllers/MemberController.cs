using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SurveyApi.Api.Models;

namespace SurveyApi.Api.Controllers;

[ApiController, Route("api/members"), Authorize(Roles = "Admin")]
public class MemberController(SiteProvider provider) : ControllerBase
{
    [HttpGet] public async Task<IActionResult> Get() => Ok(await provider.Member.GetMembers());
    [HttpGet("roles")] public async Task<IActionResult> Roles() => Ok(await provider.Member.GetRoles());

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, UpdateMemberModel model)
    {
        if (model.FullName.Trim().Length < 2) return BadRequest(new { message = "Họ tên ít nhất 2 ký tự." });
        // Quản trị viên không tự khóa hoặc tự đổi quyền để tránh mất tài khoản quản trị.
        if (id == int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!))
            return BadRequest(new { message = "Không chỉnh sửa tài khoản đang đăng nhập tại màn hình quản trị." });
        return await provider.Member.Update(id, model) == 0 ? NotFound() : Ok(new { message = "Đã cập nhật thành viên. Thành viên cần đăng nhập lại." });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        if (id == int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!))
            return BadRequest(new { message = "Không được xóa chính mình." });
        var member = await provider.Member.FindById(id);
        if (member is null) return NotFound();
        if (member.RoleName == "Admin") return BadRequest(new { message = "Chuyển Admin về Member trước khi xóa." });
        try
        {
            return await provider.Member.Delete(id) == 0 ? Conflict() : Ok(new { message = "Đã xóa thành viên." });
        }
        catch (SqlException ex) when (ex.Number == 547)
        {
            return Conflict(new { message = "Thành viên có dữ liệu liên quan. Hãy khóa tài khoản thay vì xóa." });
        }
    }
}
