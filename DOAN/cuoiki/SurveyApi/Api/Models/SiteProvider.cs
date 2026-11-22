using Microsoft.Data.SqlClient;

namespace SurveyApi.Api.Models;

public sealed class SiteProvider(IConfiguration configuration) : IDisposable
{
    private readonly SqlConnection connection = new(configuration.GetConnectionString("Survey"));
    private MemberRepository? member;
    public MemberRepository Member => member ??= new MemberRepository(connection);
    private CategoryRepository? category;
    public CategoryRepository Category => category ??= new CategoryRepository(connection);
    private SurveyRepository? survey;
    public SurveyRepository Survey => survey ??= new SurveyRepository(connection);
    private CampaignRepository? campaign;
    public CampaignRepository Campaign => campaign ??= new CampaignRepository(connection);
    public void Dispose() => connection.Dispose();
}
