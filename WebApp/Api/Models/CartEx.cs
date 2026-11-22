namespace WebApp.Api.Models;

public class CartEx : Cart
{
    public decimal Price { get; set; }
    public string ImageUrl { get; set; } = null!;
    public string BikeName { get; set; } = null!;
}