namespace WebApp.Api.Models;

public class Order
{
    public long OrderId { get; set; }
    public string? MemberId { get; set; } = null!;
    public short StatusId { get; set; }
    public string? StatusName { get; set; }
    public DateTime? OrderDate { get; set; }
}
