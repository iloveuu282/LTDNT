using System.ComponentModel.DataAnnotations;
namespace WebApp.Api.Models;
public class Category
{
    [Range(1, short.MaxValue)]
    public short CategoryId { get; set; }

    [Required, StringLength(64)]
    public string CategoryName { get; set; } = string.Empty;

    [Required, StringLength(128)]
    public string Title { get; set; } = string.Empty;

    [Required, StringLength(1024)]
    public string Description { get; set; } = string.Empty;

    [Required, StringLength(16)]
    public string Icon { get; set; } = string.Empty;
}
