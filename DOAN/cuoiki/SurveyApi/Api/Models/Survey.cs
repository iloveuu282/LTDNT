using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace SurveyApi.Api.Models;

public class Category
{
    public int CategoryId { get; set; }
    [Required, StringLength(100, MinimumLength=2)] public string CategoryName { get; set; } = "";
    [MaxLength(500)] public string? Description { get; set; }
    public string? ImagePath { get; set; }
}

public class CategoryForm
{
    [Required, StringLength(100, MinimumLength=2)] public string CategoryName { get; set; } = "";
    [MaxLength(500)] public string? Description { get; set; }
    public IFormFile? Image { get; set; }
    public bool RemoveImage { get; set; }
}

public class Survey
{
    public int SurveyId { get; set; }
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = "";
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public string ImagePath { get; set; } = "";
    public string QuestionsJson { get; set; } = "[]";
    public DateTime CreatedAt { get; set; }
    public bool IsUsed { get; set; }
    public List<Question> Questions => JsonSerializer.Deserialize<List<Question>>(QuestionsJson, JsonOptions) ?? [];
    public static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true, PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
}

public class Question
{
    public int Id { get; set; }
    public string Title { get; set; } = "";
    public string Type { get; set; } = "text";
    public bool Required { get; set; }
    public List<string> Options { get; set; } = [];
}

public class SurveyForm
{
    [Range(1,int.MaxValue)] public int CategoryId { get; set; }
    [Required, StringLength(150, MinimumLength=2)] public string Title { get; set; } = "";
    [Required, MaxLength(2000)] public string Description { get; set; } = "";
    [Required, MaxLength(100000)] public string QuestionsJson { get; set; } = "[]";
    public IFormFile? Image { get; set; }
}

public record PageResult<T>(IEnumerable<T> Items, int Total, int Page, int PageSize);

public class TargetModel
{
    [Range(1,100000)] public int TargetCount { get; set; } = 1;
}

public class CheckoutModel
{
    [Required, StringLength(150, MinimumLength=2)] public string Title { get; set; } = "";
    public Guid RequestId { get; set; }
}

public class ResponseModel
{
    public Guid SubmissionId { get; set; }
    public Dictionary<string, JsonElement> Answers { get; set; } = [];
}

public class StatusModel
{
    [Required, RegularExpression("^(Active|Closed|Cancelled)$")] public string Status { get; set; } = "";
}

public class PlanItem
{
    public int SurveyId { get; set; }
    public string Title { get; set; } = "";
    public string ImagePath { get; set; } = "";
    public int TargetCount { get; set; }
}

public class Campaign
{
    public int CampaignId { get; set; }
    public int MemberId { get; set; }
    public string FullName { get; set; } = "";
    public string Title { get; set; } = "";
    public string Status { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
}

public class CampaignItem
{
    public int ItemId { get; set; }
    public int SurveyId { get; set; }
    public string Title { get; set; } = "";
    public int TargetCount { get; set; }
    public int ResponseCount { get; set; }
    public bool HasResponded { get; set; }
}
