using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using WebApp.Api.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddAuthentication(p =>
{
    p.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    p.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(p =>
{
    p.TokenValidationParameters = new TokenValidationParameters
    {
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.ASCII.GetBytes(builder.Configuration["Jwt:SecretKey"]
            ?? throw new KeyNotFoundException("Jwt:SecretKey"))),
        ValidateLifetime = true
    };
});

builder.Services.AddScoped<SiteProvider>();
builder.Services.AddControllers();
builder.Services.AddCors(options => options.AddPolicy("DevelopmentClient", policy =>
    policy.SetIsOriginAllowed(origin =>
    {
        return Uri.TryCreate(origin, UriKind.Absolute, out var uri) && uri.IsLoopback;
    }).AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();

app.UseExceptionHandler(handler => handler.Run(async context =>
{
    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
    await context.Response.WriteAsJsonAsync(new ProblemDetails
    {
        Status = 500,
        Title = "Không thể xử lý yêu cầu. Kiểm tra log máy chủ và kết nối SQL Server."
    });
}));

if (app.Environment.IsDevelopment())
{
    app.UseCors("DevelopmentClient");
}

app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();