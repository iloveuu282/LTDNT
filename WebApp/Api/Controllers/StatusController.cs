using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;

[ApiController, Route("api/[controller]")]
public class StatusController : BaseController
{
    [HttpGet]
    public IEnumerable<Status> GetStatuses()
    {
        return Provider.Status.GetStatuses();
    }
}
