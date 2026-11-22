using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;

[Authorize]
[ApiController, Route("api/[controller]")]
public class OrderController : BaseController
{
    [HttpPost]
    public int Add(Order obj)
    {
        Random rand = new Random();
        obj.OrderId = rand.NextInt64(9999, long.MaxValue);
        obj.MemberId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Provider.Order.Add(obj);
    }

    [HttpGet]
    public IEnumerable<Order>? GetOrders()
    {
        string? memberId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (memberId != null) return Provider.Order.GetOrders(memberId);
        return null;
    }

    [HttpPut("updatestatus")]
    public int UpdateStatus(Order obj)
    {
        return Provider.Order.UpdateStatus(obj.OrderId, obj.StatusId);
    }
}
