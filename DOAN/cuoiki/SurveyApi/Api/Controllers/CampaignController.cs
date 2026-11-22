using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using SurveyApi.Api.Models;

namespace SurveyApi.Api.Controllers;

[ApiController,Route("api/campaigns"),Authorize]
public class CampaignController(SiteProvider provider):ControllerBase
{
    private int MemberId=>int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool Admin=>User.IsInRole("Admin");
    [HttpGet]
    public async Task<IActionResult> Get(bool open=false,int page=1,int pageSize=10,string? search=null,DateOnly? fromDate=null,DateOnly? toDate=null)
    {
        if(page<1 || page>100000 || pageSize<1 || pageSize>50) return BadRequest();
        if ((search?.Length??0)>150 || (fromDate.HasValue && toDate.HasValue && fromDate>toDate) || fromDate==DateOnly.MinValue || toDate==DateOnly.MaxValue)
            return BadRequest(new {message="Từ khóa hoặc khoảng ngày không hợp lệ."});
        // Ngày trên giao diện là ngày Việt Nam; SQL Server lưu UTC.
        var offset=TimeSpan.FromHours(7);
        DateTime? start=fromDate.HasValue?new DateTimeOffset(fromDate.Value.ToDateTime(TimeOnly.MinValue),offset).UtcDateTime:null;
        DateTime? end=toDate.HasValue?new DateTimeOffset(toDate.Value.AddDays(1).ToDateTime(TimeOnly.MinValue),offset).UtcDateTime:null;
        return Ok(await provider.Campaign.GetPage(MemberId,Admin,open,page,pageSize,search,start,end));
    }
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Details(int id)
    {
        var campaign=await provider.Campaign.Find(id);
        if(campaign is null) return NotFound();
        if(!Admin && campaign.MemberId!=MemberId && campaign.Status!="Active") return Forbid();
        return Ok(new {campaign,items=await provider.Campaign.Items(id,MemberId),canManage=Admin||campaign.MemberId==MemberId});
    }
    [HttpPut("{id:int}/status"),Authorize(Roles="Admin")]
    public async Task<IActionResult> Status(int id,StatusModel model)
    {
        if(await provider.Campaign.Find(id) is null) return NotFound();
        return await provider.Campaign.SetStatus(id,model.Status)==0
            ? Conflict(new {message="Chỉ cho phép: Chờ duyệt → Đang mở/Hủy; Đang mở → Đã đóng."})
            : Ok(new {message="Đã cập nhật trạng thái."});
    }
    [HttpPost("{id:int}/items/{itemId:int}/responses"),RequestSizeLimit(200000)]
    public async Task<IActionResult> Submit(int id,int itemId,ResponseModel model)
    {
        if(model.SubmissionId==Guid.Empty || model.Answers is null) return BadRequest(new {message="Dữ liệu phản hồi không hợp lệ."});
        try {await provider.Campaign.Submit(id,itemId,MemberId,model); return Ok(new {message="Đã ghi nhận phản hồi."});}
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(ArgumentException ex) {return BadRequest(new {message=ex.Message});}
        catch(InvalidOperationException ex) {return Conflict(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number is 2601 or 2627) {return Conflict(new {message="Phản hồi đã được gửi."});}
    }
    [HttpGet("{id:int}/items/{itemId:int}/results")]
    public async Task<IActionResult> Results(int id,int itemId)
    {
        var campaign=await provider.Campaign.Find(id);
        if(campaign is null) return NotFound();
        if(!Admin && campaign.MemberId!=MemberId) return Forbid();
        var item=(await provider.Campaign.Items(id,MemberId)).SingleOrDefault(i=>i.ItemId==itemId);
        if(item is null) return NotFound();
        var survey=await provider.Survey.Find(item.SurveyId);
        var rows=(await provider.Campaign.Answers(id,itemId)).Select(s=>JsonSerializer.Deserialize<Dictionary<string,JsonElement>>(s)!).ToList();
        var questions=survey!.Questions.Select(q=>
        {
            var values=rows.Where(r=>r.ContainsKey(q.Id.ToString())).Select(r=>r[q.Id.ToString()]).Where(v=>v.ValueKind is not (JsonValueKind.Null or JsonValueKind.Undefined)).ToList();
            return new {q.Id,q.Title,q.Type,
                texts=q.Type=="text"?values.Where(v=>v.ValueKind==JsonValueKind.String && !string.IsNullOrWhiteSpace(v.GetString())).Select(v=>v.GetString()).ToList():[],
                options=q.Options.Select(option=>new {label=option,count=values.Count(v=>q.Type=="multiple"?v.ValueKind==JsonValueKind.Array && v.EnumerateArray().Any(x=>x.GetString()==option):v.ValueKind==JsonValueKind.String && v.GetString()==option)}),
                average=q.Type=="rating" && values.Any(v=>v.ValueKind==JsonValueKind.Number)?(double?)values.Where(v=>v.ValueKind==JsonValueKind.Number).Average(v=>v.GetInt32()):null};
        });
        return Ok(new {total=rows.Count,questions});
    }
}
