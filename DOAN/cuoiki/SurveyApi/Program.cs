using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using SurveyApi.Api.Models;

var builder = WebApplication.CreateBuilder(args);
var secret = builder.Configuration["Jwt:SecretKey"];
// Chạy đồ án local không cần đặt biến môi trường thủ công.
if (string.IsNullOrWhiteSpace(secret) && builder.Environment.IsDevelopment())
{
    var keyFile = Path.Combine(builder.Environment.ContentRootPath, ".local-jwt-key");
    if (!File.Exists(keyFile))
        File.WriteAllText(keyFile, Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(48)));
    secret = File.ReadAllText(keyFile).Trim();
    builder.Configuration["Jwt:SecretKey"] = secret;
}
if (string.IsNullOrWhiteSpace(secret) || Encoding.UTF8.GetByteCount(secret) < 32)
    throw new InvalidOperationException("Cần cấu hình Jwt__SecretKey có ít nhất 32 byte.");
builder.Services.AddControllers();
builder.Services.AddScoped<SiteProvider>();
builder.Services.AddScoped<SurveyApi.Services.ImageService>();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
{
    options.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var idText = context.Principal?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(idText, out var id)) { context.Fail("Invalid member"); return; }
            var provider = context.HttpContext.RequestServices.GetRequiredService<SiteProvider>();
            var member = await provider.Member.FindById(id);
            if (member is null || !member.IsActive ||
                context.Principal?.FindFirst("version")?.Value != member.TokenVersion.ToString() ||
                context.Principal?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value != member.RoleName)
                context.Fail("Session expired");
        }
    };
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
        ClockSkew = TimeSpan.FromSeconds(30)
    };
});
builder.Services.AddAuthorization();
var app = builder.Build();
Directory.CreateDirectory(Path.Combine(app.Environment.ContentRootPath, "wwwroot", "uploads"));
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(
        Path.Combine(app.Environment.ContentRootPath, "wwwroot"))
});
app.UseExceptionHandler(handler => handler.Run(async context =>
{
    context.Response.StatusCode = 500;
    await context.Response.WriteAsJsonAsync(new { message = "Không thể xử lý yêu cầu. Vui lòng kiểm tra máy chủ." });
}));
app.UseAuthentication();
app.UseAuthorization();
app.MapGet("/api/health", () => Results.Ok(new { status = "ok" }));
app.MapControllers();
app.Lifetime.ApplicationStarted.Register(() =>
{
    foreach(var address in app.Urls)
    {
        if(!Uri.TryCreate(address,UriKind.Absolute,out var uri) || uri.Host!="0.0.0.0") continue;
        foreach(var adapter in System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
            .Where(n=>n.OperationalStatus==System.Net.NetworkInformation.OperationalStatus.Up &&
                n.NetworkInterfaceType is System.Net.NetworkInformation.NetworkInterfaceType.Wireless80211 or System.Net.NetworkInformation.NetworkInterfaceType.Ethernet))
        foreach(var ip in adapter.GetIPProperties().UnicastAddresses.Where(a=>a.Address.AddressFamily==System.Net.Sockets.AddressFamily.InterNetwork))
            app.Logger.LogInformation("Điện thoại cùng Wi-Fi: mở Kết nối máy chủ và nhập http://{Ip}:{Port}",ip.Address,uri.Port);
    }
});
app.Run();
