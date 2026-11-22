using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SurveyApi.Api.Models;

namespace SurveyApi.Api.Controllers;

[ApiController,Route("api/plan"),Authorize]
public class PlanController(SiteProvider provider):ControllerBase
{
    private int MemberId=>int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    [HttpGet] public async Task<IActionResult> Get()=>Ok(await provider.Campaign.GetPlan(MemberId));
    [HttpPut("{surveyId:int}")]
    public async Task<IActionResult> Put(int surveyId,TargetModel model)
    {
        try { await provider.Campaign.PutPlan(MemberId,surveyId,model.TargetCount); return Ok(new {message="Đã cập nhật kế hoạch."}); }
        catch(SqlException ex) when(ex.Number==547) {return NotFound(new {message="Mẫu khảo sát không tồn tại."});}
    }
    [HttpDelete("{surveyId:int}")]
    public async Task<IActionResult> Delete(int surveyId)
    {
        await provider.Campaign.RemovePlan(MemberId,surveyId);
        return Ok(new {message="Đã bỏ mẫu khỏi kế hoạch."});
    }
    [HttpPost("checkout")]
    public async Task<IActionResult> Checkout(CheckoutModel model)
    {
        if(model.RequestId==Guid.Empty || model.Title.Trim().Length<2) return BadRequest(new {message="Nhập tên chiến dịch và mã xác nhận hợp lệ."});
        try {return Ok(new {campaignId=await provider.Campaign.Checkout(MemberId,model)});}
        catch(InvalidOperationException ex) {return Conflict(new {message=ex.Message});}
    }
}
