using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;

[ApiController, Route("api/[controller]")]
public class AuthController : BaseController
{
    [HttpPost("register")]
    public int Add(Member obj)
    {
        ModelState.Remove(nameof(obj.MemberId));
        if (ModelState.IsValid)
        {
            return Provider.Member.Add(obj);
        }
        return -2;
    }

    [HttpPost("login")]
    public LoginResult Login(LoginModel obj)
    {
        LoginResult result = Provider.Member.Login(obj, HttpContext.RequestServices.GetRequiredService<IConfiguration>());

        return result;
    }
}