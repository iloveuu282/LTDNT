-- Truy vấn CHỈ ĐỌC để minh họa bằng SSMS, không tự tạo/sửa/xóa dữ liệu.
-- Thay email mẫu bằng tài khoản thử mà bạn chủ động đăng ký trong app.
-- Không SELECT PasswordHash hoặc token.
USE BusinessSurvey;
DECLARE @Email VARCHAR(254) = 'tai_khoan_mau@example.com';

-- 1. Tài khoản đã đăng ký trên điện thoại.
SELECT m.MemberId, m.FullName, m.Email, r.RoleName, m.IsActive, m.CreatedAt
FROM dbo.Members AS m
JOIN dbo.Roles AS r ON r.RoleId=m.RoleId
WHERE m.Email=@Email;

-- 2. Kế hoạch của tài khoản trước khi tạo chiến dịch.
SELECT p.MemberId, p.SurveyId, s.Title, p.TargetCount
FROM dbo.PlanItems AS p
JOIN dbo.Members AS m ON m.MemberId=p.MemberId
JOIN dbo.Surveys AS s ON s.SurveyId=p.SurveyId
WHERE m.Email=@Email;

-- 3. Chiến dịch và từng mẫu do tài khoản sở hữu.
SELECT c.CampaignId, c.Title AS CampaignTitle, c.Status, c.CreatedAt,
       i.ItemId, s.Title AS SurveyTitle, i.TargetCount
FROM dbo.Campaigns AS c
JOIN dbo.Members AS m ON m.MemberId=c.MemberId
JOIN dbo.CampaignItems AS i ON i.CampaignId=c.CampaignId
JOIN dbo.Surveys AS s ON s.SurveyId=i.SurveyId
WHERE m.Email=@Email
ORDER BY c.CampaignId DESC, i.ItemId;

-- 4. Các phản hồi chính tài khoản đã gửi, không hiển thị nội dung trả lời riêng tư.
SELECT r.ResponseId, r.ItemId, i.CampaignId, s.Title AS SurveyTitle, r.CreatedAt
FROM dbo.Responses AS r
JOIN dbo.Members AS m ON m.MemberId=r.MemberId
JOIN dbo.CampaignItems AS i ON i.ItemId=r.ItemId
JOIN dbo.Surveys AS s ON s.SurveyId=i.SurveyId
WHERE m.Email=@Email
ORDER BY r.ResponseId DESC;
