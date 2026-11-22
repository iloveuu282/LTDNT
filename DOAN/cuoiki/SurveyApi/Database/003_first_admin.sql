-- Chạy một lần để cấp quyền Admin cho tài khoản bạn đã đăng ký.
-- Thay email bên dưới bằng email của bạn trước khi chạy file.
USE BusinessSurvey;
GO
DECLARE @Email VARCHAR(254) = 'YOUR_EMAIL@example.com';
IF @Email = 'YOUR_EMAIL@example.com'
    THROW 50001, N'Hãy thay YOUR_EMAIL@example.com bằng email đã đăng ký.', 1;
IF NOT EXISTS (SELECT 1 FROM Members WHERE Email = @Email)
    THROW 50002, N'Không tìm thấy tài khoản. Hãy đăng ký trong app trước.', 1;
UPDATE Members
SET RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Admin'),
    IsActive = 1, TokenVersion = TokenVersion + 1
WHERE Email = @Email;
PRINT N'Đã cấp quyền Admin. Đăng xuất và đăng nhập lại trên app.';
