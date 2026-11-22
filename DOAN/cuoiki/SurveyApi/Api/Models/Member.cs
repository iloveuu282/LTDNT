using System.ComponentModel.DataAnnotations;

namespace SurveyApi.Api.Models;

public class Member
{
    public int MemberId { get; set; }
    public string FullName { get; set; } = "";
    public string Email { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string RoleName { get; set; } = "Member";
    public bool IsActive { get; set; } = true;
    public int TokenVersion { get; set; }
}

public class LoginModel
{
    [Required, EmailAddress, MaxLength(254)] public string Email { get; set; } = "";
    [Required, StringLength(64, MinimumLength = 8)] public string Password { get; set; } = "";
}

public class RegisterModel : LoginModel
{
    [Required, StringLength(100, MinimumLength = 2)] public string FullName { get; set; } = "";
}

public class ChangePasswordModel
{
    [Required] public string CurrentPassword { get; set; } = "";
    [Required, StringLength(64, MinimumLength = 8)] public string NewPassword { get; set; } = "";
}

public class UpdateMemberModel
{
    [Required, StringLength(100, MinimumLength = 2)] public string FullName { get; set; } = "";
    [Required, RegularExpression("^(Admin|Member)$")] public string RoleName { get; set; } = "Member";
    public bool IsActive { get; set; } = true;
}
