using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
namespace WebApp.Api.Controllers;
public abstract class BaseController : ControllerBase
{SiteProvider? provider;
    protected SiteProvider Provider => provider
        ??= HttpContext.RequestServices.GetRequiredService<SiteProvider>();
}