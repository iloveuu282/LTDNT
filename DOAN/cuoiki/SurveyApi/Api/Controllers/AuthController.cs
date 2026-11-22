using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.IdentityModel.Tokens;
using SurveyApi.Api.Models;

namespace SurveyApi.Api.Controllers;

[ApiController, Route("api/auth")]
public class AuthController(SiteProvider provider, IConfiguration configuration) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterModel model)
    {
        if (model.FullName.Trim().Length < 2)
            return BadRequest(new { message = "Họ tên phải có ít nhất 2 ký tự." });
        try
        {
            var id = await provider.Member.Add(model);
            return StatusCode(201, new { memberId = id, message = "Đăng ký thành công. Vui lòng đăng nhập." });
        }
        catch (SqlException ex) when (ex.Number is 2601 or 2627)
        {
            return Conflict(new { message = "Email đã được đăng ký." });
        }
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginModel model)
    {
        var member = await provider.Member.FindByEmail(model.Email.Trim().ToLowerInvariant());
        if (member is null || !member.IsActive || !BCrypt.Net.BCrypt.Verify(model.Password, member.PasswordHash))
            return Unauthorized(new { message = "Email hoặc mật khẩu không đúng." });
        var expires = DateTime.UtcNow.AddHours(8);
        var token = new JwtSecurityToken(configuration["Jwt:Issuer"], configuration["Jwt:Audience"],
            [new Claim(ClaimTypes.NameIdentifier, member.MemberId.ToString()),
             new Claim(ClaimTypes.Role, member.RoleName),
             new Claim("version", member.TokenVersion.ToString())],
            expires: expires,
            signingCredentials: new SigningCredentials(new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(configuration["Jwt:SecretKey"]!)), SecurityAlgorithms.HmacSha256));
        return Ok(new { token = new JwtSecurityTokenHandler().WriteToken(token), expiresAt = expires,
            member = PublicMember(member) });
    }

    [Authorize, HttpGet("me")]
    public async Task<IActionResult> Me()
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var id)) return Unauthorized();
        var member = await provider.Member.FindById(id);
        return member is null ? Unauthorized() : Ok(PublicMember(member));
    }

    [Authorize, HttpPost("change-password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordModel model)
    {
        var id = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var member = await provider.Member.FindById(id);
        if (member is null) return Unauthorized();
        if (!BCrypt.Net.BCrypt.Verify(model.CurrentPassword, member.PasswordHash))
            return BadRequest(new { message = "Mật khẩu hiện tại không đúng." });
        if (model.CurrentPassword == model.NewPassword)
            return BadRequest(new { message = "Mật khẩu mới phải khác mật khẩu hiện tại." });
        if (await provider.Member.ChangePassword(id, member.PasswordHash, model.NewPassword) == 0)
            return Conflict(new { message = "Tài khoản đã thay đổi. Vui lòng đăng nhập lại." });
        return Ok(new { message = "Đổi mật khẩu thành công. Vui lòng đăng nhập lại." });
    }

    [Authorize, HttpPost("logout")]
    public async Task<IActionResult> Logout()
    {
        await provider.Member.Logout(int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!));
        return Ok(new { message = "Đã đăng xuất các phiên của tài khoản." });
    }

    private static object PublicMember(Member member) => new
    { member.MemberId, member.FullName, member.Email, member.RoleName };
}
