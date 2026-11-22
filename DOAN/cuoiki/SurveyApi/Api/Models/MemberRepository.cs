using System.Data;
using Dapper;

namespace SurveyApi.Api.Models;

public class MemberRepository(IDbConnection connection) : BaseRepository(connection)
{
    public Task<Member?> FindByEmail(string email) => connection.QuerySingleOrDefaultAsync<Member>(
        """
        SELECT m.*, r.RoleName
        FROM Members m JOIN Roles r ON r.RoleId = m.RoleId WHERE m.Email = @email
        """, new { email });

    public Task<Member?> FindById(int id) => connection.QuerySingleOrDefaultAsync<Member>(
        """
        SELECT m.*, r.RoleName
        FROM Members m JOIN Roles r ON r.RoleId = m.RoleId WHERE m.MemberId = @id
        """, new { id });

    public Task<int> Add(RegisterModel model) => connection.QuerySingleAsync<int>(
        """
        INSERT INTO Members (FullName, Email, PasswordHash, RoleId)
        OUTPUT INSERTED.MemberId
        VALUES (@FullName, @Email, @PasswordHash, (SELECT RoleId FROM Roles WHERE RoleName = 'Member'))
        """, new { FullName = model.FullName.Trim(), Email = model.Email.Trim().ToLowerInvariant(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.Password) });

    public Task<IEnumerable<object>> GetMembers() => connection.QueryAsync<object>(
        """
        SELECT m.MemberId AS memberId, m.FullName AS fullName, m.Email AS email, m.IsActive AS isActive, r.RoleName AS roleName
        FROM Members m JOIN Roles r ON r.RoleId = m.RoleId ORDER BY m.MemberId DESC
        """);

    public Task<IEnumerable<string>> GetRoles() => connection.QueryAsync<string>("SELECT RoleName FROM Roles ORDER BY RoleId");

    public Task<int> ChangePassword(int id, string oldHash, string newPassword) => connection.ExecuteAsync(
        "UPDATE Members SET PasswordHash=@hash, TokenVersion=TokenVersion+1 WHERE MemberId=@id AND PasswordHash=@oldHash",
        new { id, oldHash, hash = BCrypt.Net.BCrypt.HashPassword(newPassword) });

    public Task<int> Logout(int id) => connection.ExecuteAsync(
        "UPDATE Members SET TokenVersion=TokenVersion+1 WHERE MemberId=@id", new { id });

    public Task<int> Update(int id, UpdateMemberModel model) => connection.ExecuteAsync(
        """
        UPDATE Members SET FullName=@FullName, IsActive=@IsActive,
            RoleId=(SELECT RoleId FROM Roles WHERE RoleName=@RoleName), TokenVersion=TokenVersion+1
        WHERE MemberId=@id
        """, new { id, FullName = model.FullName.Trim(), model.RoleName, model.IsActive });

    // Chỉ xóa Member; Admin phải được chuyển về Member trước.
    public Task<int> Delete(int id) => connection.ExecuteAsync(
        "DELETE FROM Members WHERE MemberId=@id AND RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Member')", new { id });
}
