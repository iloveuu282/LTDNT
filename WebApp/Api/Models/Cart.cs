namespace WebApp.Api.Models;

public class Cart
{
    public string? MemberId { get; set; }
    public int BikeId { get; set; }
    public short Quantity { get; set; }
}