using System.Data;
using System.Text.Json;
using Dapper;

namespace SurveyApi.Api.Models;

public class CampaignRepository(IDbConnection connection) : BaseRepository(connection)
{
    public Task<IEnumerable<PlanItem>> GetPlan(int memberId) => connection.QueryAsync<PlanItem>(
        "SELECT p.SurveyId,s.Title,s.ImagePath,p.TargetCount FROM PlanItems p JOIN Surveys s ON p.SurveyId=s.SurveyId WHERE MemberId=@memberId ORDER BY p.SurveyId",new { memberId });

    public async Task PutPlan(int memberId,int surveyId,int count)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        await connection.ExecuteAsync("""
            IF EXISTS(SELECT 1 FROM PlanItems WITH (UPDLOCK,HOLDLOCK) WHERE MemberId=@memberId AND SurveyId=@surveyId)
                UPDATE PlanItems SET TargetCount=@count WHERE MemberId=@memberId AND SurveyId=@surveyId;
            ELSE INSERT INTO PlanItems(MemberId,SurveyId,TargetCount) VALUES(@memberId,@surveyId,@count);
            """,new { memberId,surveyId,count },tx);
        tx.Commit();
    }
    public Task<int> RemovePlan(int memberId,int surveyId) => connection.ExecuteAsync(
        "DELETE FROM PlanItems WHERE MemberId=@memberId AND SurveyId=@surveyId",new { memberId,surveyId });

    public async Task<int> Checkout(int memberId,CheckoutModel model)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var existing=await connection.QuerySingleOrDefaultAsync<int?>(
            "SELECT CampaignId FROM Campaigns WITH (UPDLOCK,HOLDLOCK) WHERE MemberId=@memberId AND RequestId=@RequestId",new { memberId,model.RequestId },tx);
        if (existing.HasValue) return existing.Value;
        var plan=(await connection.QueryAsync<PlanItem>(
            "SELECT * FROM PlanItems WITH (UPDLOCK,HOLDLOCK) WHERE MemberId=@memberId",new { memberId },tx)).ToList();
        if (plan.Count==0) throw new InvalidOperationException("Kế hoạch chưa có mẫu khảo sát.");
        // Giữ khóa mẫu đến khi ghi CampaignItems để không sửa câu hỏi giữa lúc triển khai.
        await connection.QueryAsync<int>("SELECT SurveyId FROM Surveys WITH (HOLDLOCK) WHERE SurveyId IN @ids",new { ids=plan.Select(p=>p.SurveyId) },tx);
        var id=await connection.QuerySingleAsync<int>(
            "INSERT INTO Campaigns(MemberId,Title,RequestId) OUTPUT INSERTED.CampaignId VALUES(@memberId,@title,@RequestId)",new { memberId,title=model.Title.Trim(),model.RequestId },tx);
        foreach (var item in plan)
            await connection.ExecuteAsync("INSERT INTO CampaignItems(CampaignId,SurveyId,TargetCount) VALUES(@id,@SurveyId,@TargetCount)",new { id,item.SurveyId,item.TargetCount },tx);
        await connection.ExecuteAsync("DELETE FROM PlanItems WHERE MemberId=@memberId",new { memberId },tx);
        tx.Commit();
        return id;
    }

    public async Task<PageResult<Campaign>> GetPage(int memberId,bool admin,bool open,int page,int size,string? search,DateTime? start,DateTime? end)
    {
        const string where="""
             WHERE ((@open=1 AND c.Status='Active') OR (@open=0 AND (@admin=1 OR c.MemberId=@memberId)))
             AND (c.Title LIKE @keyword OR c.CampaignId=@code)
             AND (@start IS NULL OR c.CreatedAt>=@start) AND (@end IS NULL OR c.CreatedAt<@end)
            """;
        var keyword=(search??"").Trim();
        int? code=int.TryParse(keyword.TrimStart('#'),out var number)?number:null;
        var args=new { memberId,admin,open,keyword="%"+keyword+"%",code,start,end,skip=(page-1)*size,size };
        var total=await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Campaigns c"+where,args);
        var items=await connection.QueryAsync<Campaign>("SELECT c.*,m.FullName FROM Campaigns c JOIN Members m ON m.MemberId=c.MemberId"+where+" ORDER BY c.CampaignId DESC OFFSET @skip ROWS FETCH NEXT @size ROWS ONLY",args);
        return new(items,total,page,size);
    }
    public Task<Campaign?> Find(int id) => connection.QuerySingleOrDefaultAsync<Campaign>(
        "SELECT c.*,m.FullName FROM Campaigns c JOIN Members m ON m.MemberId=c.MemberId WHERE CampaignId=@id",new { id });
    public Task<IEnumerable<CampaignItem>> Items(int id,int memberId) => connection.QueryAsync<CampaignItem>("""
        SELECT i.ItemId,i.SurveyId,s.Title,i.TargetCount,
          (SELECT COUNT(*) FROM Responses r WHERE r.ItemId=i.ItemId) AS ResponseCount,
          CAST(CASE WHEN EXISTS(SELECT 1 FROM Responses r WHERE r.ItemId=i.ItemId AND r.MemberId=@memberId) THEN 1 ELSE 0 END AS BIT) AS HasResponded
        FROM CampaignItems i JOIN Surveys s ON s.SurveyId=i.SurveyId WHERE CampaignId=@id ORDER BY i.ItemId
        """,new { id,memberId });
    public Task<int> SetStatus(int id,string status) => connection.ExecuteAsync("""
        UPDATE Campaigns SET Status=@status WHERE CampaignId=@id AND
        ((Status='Pending' AND @status IN ('Active','Cancelled')) OR (Status='Active' AND @status='Closed'))
        """,new { id,status });

    public async Task Submit(int campaignId,int itemId,int memberId,ResponseModel model)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var status=await connection.QuerySingleOrDefaultAsync<string>("SELECT Status FROM Campaigns WITH (UPDLOCK,HOLDLOCK) WHERE CampaignId=@campaignId",new { campaignId },tx);
        var item=await connection.QuerySingleOrDefaultAsync<CampaignItem>("SELECT * FROM CampaignItems WHERE CampaignId=@campaignId AND ItemId=@itemId",new { campaignId,itemId },tx);
        if (item is null) throw new KeyNotFoundException("Không tìm thấy khảo sát trong chiến dịch.");
        var previous=await connection.QuerySingleOrDefaultAsync<Guid?>("SELECT SubmissionId FROM Responses WHERE ItemId=@itemId AND MemberId=@memberId",new { itemId,memberId },tx);
        if (previous==model.SubmissionId) return; // thử gửi lại cùng mã không tạo bản ghi trùng
        if (previous.HasValue) throw new InvalidOperationException("Bạn đã trả lời khảo sát này.");
        if (status!="Active") throw new InvalidOperationException("Chiến dịch chưa mở hoặc đã kết thúc.");
        var count=await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Responses WHERE ItemId=@itemId",new { itemId },tx);
        if (count>=item.TargetCount) throw new InvalidOperationException("Khảo sát đã đủ số phản hồi mục tiêu.");
        var survey=await connection.QuerySingleAsync<Survey>("SELECT * FROM Surveys WHERE SurveyId=@SurveyId",new { item.SurveyId },tx);
        SurveyRules.ValidateAnswers(survey.Questions,model.Answers);
        await connection.ExecuteAsync("INSERT INTO Responses(ItemId,MemberId,SubmissionId,AnswersJson) VALUES(@itemId,@memberId,@SubmissionId,@json)",
            new { itemId,memberId,model.SubmissionId,json=JsonSerializer.Serialize(model.Answers) },tx);
        tx.Commit();
    }
    public Task<IEnumerable<string>> Answers(int campaignId,int itemId) => connection.QueryAsync<string>(
        "SELECT r.AnswersJson FROM Responses r JOIN CampaignItems i ON i.ItemId=r.ItemId WHERE i.CampaignId=@campaignId AND i.ItemId=@itemId ORDER BY r.ResponseId",new { campaignId,itemId });
}
