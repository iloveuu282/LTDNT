using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;

[Authorize]
[ApiController, Route("api/[controller]")]
public class CartController : BaseController
{
    [HttpPost]
    public int Add(Cart obj)
    {
        obj.MemberId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Provider.Cart.Add(obj);
    }

    [HttpGet]
    public IEnumerable<CartEx>? GetCarts()
    {
        string? memberId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (memberId != null) return Provider.Cart.GetCarts(memberId);
        return null;
    }

    [HttpDelete("{id}")]
    public int Delete(int id)
    {
        string? memberId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(memberId)) return -1;
        return Provider.Cart.Delete(id, memberId);
    }
}