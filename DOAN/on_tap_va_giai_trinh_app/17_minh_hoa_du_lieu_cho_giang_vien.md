# Minh họa dữ liệu cho giảng viên

## Ví dụ đăng ký từ điện thoại

Tạo tài khoản trên app không có nghĩa tài khoản lưu trong SQLite điện thoại. Điện thoại nhập và gửi dữ liệu; API trên laptop kiểm tra và ghi vào SQL Server. Database hiện tại là BusinessSurvey, bảng Members; RoleId liên kết Roles và tài khoản đăng ký mới là Member.

```text
LoginPage ở chế độ đăng ký
    → MemberRepository.register → _post
    → HTTP POST /api/auth/register
    → AuthController.Register
    → MemberRepository.Add phía C#
    → INSERT vào BusinessSurvey.dbo.Members trên laptop
    → API trả kết quả để app báo đăng ký thành công
```

Mật khẩu được gửi tới API để xử lý rồi lưu dạng BCrypt hash trong PasswordHash; không lưu mật khẩu rõ. Luồng đăng ký không lưu tài khoản vào SQLite và chưa tự đăng nhập. Khi đăng nhập thành công sau đó, API mới cấp token, app lưu token/hồ sơ vào Secure Storage.

## Cách cho giảng viên xem bằng SQL Server Management Studio

1. Trên laptop, SQL Server và API đang chạy; điện thoại kết nối đúng máy chủ đó.
2. Mở SQL Server Management Studio (SSMS), kết nối server `.\SQLEXPRESS` bằng Windows Authentication, chọn database BusinessSurvey.
3. Mở New Query. Đặt email mẫu của bạn trong biến @Email rồi chạy SELECT bên dưới trước khi đăng ký; email chưa tồn tại thì chưa có dòng.
4. Trên điện thoại đăng ký bằng đúng email đó và thông tin rõ nghĩa. Chờ app báo thành công.
5. Chạy lại đúng SELECT. Dòng tài khoản xuất hiện với MemberId, FullName, Email và RoleName là Member. Đây là bằng chứng dữ liệu được ghi từ điện thoại qua API vào database trên laptop.
6. Đăng nhập tài khoản mới trên app; nếu cần đăng nhập cùng tài khoản trên điện thoại khác đang kết nối cùng API để chứng minh dữ liệu tập trung.

```sql
USE BusinessSurvey;
DECLARE @Email VARCHAR(254) = 'tai_khoan_mau@example.com';

SELECT m.MemberId, m.FullName, m.Email,
       r.RoleName, m.IsActive, m.CreatedAt
FROM dbo.Members AS m
JOIN dbo.Roles AS r ON r.RoleId = m.RoleId
WHERE m.Email = @Email;
```

Thay email ví dụ bằng email tài khoản thử bạn chủ động tạo. Truy vấn chỉ đọc, không sửa hoặc xóa dữ liệu. Không dùng SELECT * hoặc đưa PasswordHash/token vào màn hình minh chứng. CreatedAt lưu UTC nên có thể lệch 7 giờ so với giờ Việt Nam; đó không phải tài khoản lưu sai thời điểm.

Nếu giáo viên muốn xem bằng giao diện SSMS: Object Explorer → Databases → BusinessSurvey → Tables có dbo.Members và dbo.Roles. Dùng New Query với cột chọn rõ ràng dễ minh họa hơn Edit Top Rows vì không vô tình sửa dữ liệu. Khi bạn đã chạy lại SELECT thì thấy dữ liệu mới; không phải chờ đồng bộ định kỳ.

## Mở code nào để giải thích ngay

| Bước | File và hàm |
| --- | --- |
| Nút đăng ký | [login_page.dart](<../cuoiki/survey_app/lib/pages/login_page.dart>) — dòng 30 |
| Gửi HTTP | [member_repository.dart](<../cuoiki/survey_app/lib/repositories/member_repository.dart>) — dòng 94 và `_post` trong cùng file |
| Endpoint server | [AuthController.cs](<../cuoiki/SurveyApi/Api/Controllers/AuthController.cs>) — dòng 16 |
| INSERT và BCrypt | [MemberRepository.cs](<../cuoiki/SurveyApi/Api/Models/MemberRepository.cs>) — dòng 20 |
| Cấu trúc bảng Members | [001_initial.sql](<../cuoiki/SurveyApi/Database/001_initial.sql>) — dòng 16 |

## Câu giải thích có thể nói

“Em đăng ký trên điện thoại nhưng dữ liệu tài khoản lưu tập trung trong SQL Server trên laptop. Flutter gọi endpoint đăng ký, C# kiểm tra rồi INSERT bảng Members; mật khẩu được băm BCrypt. Em chạy lại SELECT theo email để thấy dòng mới và vai trò Member. SQLite chỉ dùng để lưu nháp trả lời, không phải nơi lưu tài khoản của hệ thống.”

## Các ví dụ tương tự

| Thao tác trên app | Dữ liệu được lưu hoặc đọc ở đâu | Cách minh họa |
| --- | --- | --- |
| Đăng nhập | Đọc Members/Roles trên SQL Server; ghi token và hồ sơ vào Secure Storage | Đăng nhập đúng/sai; mở AuthController.Login và SessionHelper.save |
| Admin thay role hoặc khóa | Members.RoleId, IsActive, TokenVersion | SELECT email trước/sau; request với token cũ bị từ chối |
| Tạo danh mục có ảnh | Categories.ImagePath và file wwwroot/uploads | Xem danh mục trên app, đường dẫn trong SQL, file ảnh trên laptop |
| Tạo mẫu và câu hỏi | Surveys và QuestionsJson | Xem mẫu/câu hỏi trên app rồi đối chiếu SurveyRepository.Add |
| Thêm vào kế hoạch | PlanItems theo MemberId/SurveyId | SELECT kế hoạch của tài khoản; badge đếm số mẫu |
| Xác nhận tạo chiến dịch | Campaigns/CampaignItems; PlanItems được làm trống | Xem chi tiết và SELECT trước/sau theo tài khoản |
| Chỉ lưu nháp | response_drafts SQLite trên chính điện thoại | Lưu nháp, ngắt kết nối, đóng/mở app và mở lại nháp |
| Gửi phản hồi thành công | Responses SQL Server; nháp tương ứng trên điện thoại bị xóa | Xem số phản hồi/kết quả và SELECT dòng Response |
| Thay địa chỉ máy chủ | Secure Storage khóa server_url trên điện thoại | Thoát/mở app và kiểm tra địa chỉ còn giữ |

Script `phu_luc/truy_van_minh_hoa_chi_doc.sql` có sẵn các SELECT tài khoản, kế hoạch, chiến dịch và phản hồi theo email. Nó không tự đăng ký, đổi role hoặc xóa dữ liệu. Chỉ các thao tác bạn thực hiện trong app mới làm phát sinh thay đổi cần minh họa.

## Làm sao chứng minh SQLite khi SSMS không nhìn thấy

SSMS kết nối SQL Server, không tự đọc SQLite trong vùng dữ liệu riêng của Android. Với bản release hiện tại, không nên hứa chỉ cần adb run-as là lấy được database vì release không debuggable.

Cách đơn giản là lưu một nháp có nội dung dễ nhận biết, làm mất kết nối máy chủ rồi mở lại nháp trong app. Mở LocalDatabase.saveDraft và ResponsePage._load/_store để chỉ rõ bảng và payload. Nếu giảng viên yêu cầu trực tiếp xem file .db bằng công cụ thì cần chuẩn bị riêng môi trường kiểm thử phù hợp; app hiện chưa có chức năng xuất database/nháp.

Các minh chứng kỹ thuật SQLite trên Android đã lưu trong DOAN/tai_nguyen_bao_cao/05_kiem_thu và 06_anh_minh_chung/kiem_thu_ky_thuat. Phân biệt minh chứng kiểm thử đã ghi với ảnh demo chức năng mới bạn chụp.

## Khi đổi điện thoại hoặc laptop

Điện thoại mới kết nối cùng API/database và đăng nhập thì đọc dữ liệu tập trung theo quyền. Nháp, URL và phiên cục bộ không có cơ chế đồng bộ do app tự triển khai. APK chứa mã và tài nguyên ứng dụng, không chứa các tài khoản/chiến dịch/nháp đã phát sinh từ thiết bị cũ.

Laptop mới không tự có database/file ảnh từ laptop cũ. Cần chuẩn bị SQL Server, cấu hình API và chuyển dữ liệu/ảnh bằng kế hoạch sao lưu phù hợp nếu muốn giữ dữ liệu. Các script schema trong bộ tài nguyên chỉ tạo cấu trúc, không thay thế backup dữ liệu thực tế.

SSMS có thể đóng sau khi kiểm tra; dịch vụ SQL Server và API vẫn phải chạy để app làm việc online. Tắt API/laptop không tự xóa dữ liệu, chỉ khiến điện thoại không truy cập được dữ liệu tập trung lúc đó.
