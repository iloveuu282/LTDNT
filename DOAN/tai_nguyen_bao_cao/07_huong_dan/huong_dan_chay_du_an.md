# Chạy đồ án

## Cách chạy hằng ngày trên điện thoại Android qua USB

Để chạy bản cài độc lập sau khi rút USB, xem [hướng dẫn Wi-Fi và bản hoàn thiện](../../docs/app-completion-wifi.md). Cách chạy qua USB bên dưới vẫn được giữ để phát triển.

Cắm điện thoại, bật gỡ lỗi USB và chấp nhận cấp quyền trước khi chạy API.

Terminal 1:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\SurveyApi
dotnet run
```

Terminal 2:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\survey_app
flutter run
```

Chọn điện thoại nếu Flutter hiện danh sách thiết bị. Giữ terminal API mở.

## Những việc được tự cấu hình

- API chạy Development trên cổng 5080 cho cả localhost và mạng nội bộ qua launchSettings.json. Terminal in địa chỉ Wi-Fi để nhập trong app.
- Nếu chưa có Jwt:SecretKey, API tự tạo khóa local trong .local-jwt-key, được gitignore. Production vẫn yêu cầu cấu hình khóa riêng.
- Khi build API Debug trên Windows, tự gọi adb -d reverse tcp:5080 tcp:5080 nếu tìm thấy Android SDK. Chỉ nhắm một điện thoại USB.
- Flutter mặc định gọi http://localhost:5080; mục Kết nối máy chủ cho phép lưu địa chỉ Wi-Fi. Địa chỉ đã lưu dùng chung cho đăng nhập, dữ liệu và upload ảnh, giữ qua khởi động lại và đăng xuất.
- Gradle wrapper dùng cache .gradle-local của dự án nếu chưa đặt GRADLE_USER_HOME.
- Nếu cắm lại cáp sau khi API đã chạy, chạy lại dotnet run để thiết lập chuyển tiếp USB, hoặc dùng run-phone.ps1.

## Chuẩn bị một lần trên máy mới

Cài .NET 10, Flutter và Android SDK. SQL Server Express hiện dùng Windows Authentication. Chạy script sau nếu chưa có database:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki
sqlcmd -S '.\SQLEXPRESS' -E -C -b -i SurveyApi/Database/001_initial.sql
sqlcmd -S '.\SQLEXPRESS' -E -C -b -i SurveyApi/Database/002_member_management.sql
sqlcmd -S '.\SQLEXPRESS' -E -C -b -i SurveyApi/Database/004_surveys_campaigns.sql
sqlcmd -S '.\SQLEXPRESS' -E -C -b -i SurveyApi/Database/005_category_images.sql
```

Nếu dùng SQL Server khác, sửa ConnectionStrings:Survey trong SurveyApi/appsettings.json.

## Kiểm tra

Đăng ký tài khoản, thử email trùng, đăng nhập sai/đúng rồi đăng xuất. Tài khoản mới luôn là Member.

Bản bắt buộc đã có danh mục, mẫu và câu hỏi, ảnh, tìm kiếm/phân trang, kế hoạch, chiến dịch, trả lời, nháp SQLite và thống kê. Xem [checklist test toàn bộ](../../docs/full-test-checklist.md) theo thứ tự để kiểm tra các chức năng trên điện thoại. Database máy hiện tại đã cập nhật file 004, không cần chạy lại.

API hiện có: POST /api/auth/register, POST /api/auth/login, GET /api/auth/me (Bearer token), GET /api/health.

## Cập nhật phần tài khoản

Database trên máy này đã được cập nhật bằng `SurveyApi/Database/002_member_management.sql`. Máy mới chạy file 001 rồi 002 một lần; không mất dữ liệu cũ. Sau khi thay code, dừng API bằng Ctrl+C rồi chạy lại `dotnet run`; dừng Flutter và chạy lại `flutter run` để nhận đủ thay đổi.

- Cả Admin và Member đều có mục Đổi mật khẩu, kiểm tra mật khẩu hiện tại và xác nhận mật khẩu mới.
- Đổi mật khẩu thành công phải đăng nhập lại; các token cũ bị thu hồi.
- Admin có mục Thành viên và vai trò: danh sách, sửa họ tên, khóa/mở, gán Admin hoặc Member, xóa Member chưa có dữ liệu liên quan.
- Vai trò hệ thống giữ cố định Admin/Member, chưa thêm chức năng tạo role tùy ý.
- Không sửa/xóa chính mình trong màn hình quản trị. Chuyển Admin khác về Member trước khi xóa.
- Mỗi lần sửa tài khoản, tài khoản đó phải đăng nhập lại. Tài khoản khóa không đăng nhập được.
- Member bị chặn ở API quản trị, không chỉ ẩn nút trên app.

### Cấp Admin đầu tiên

Không có tài khoản Admin hay mật khẩu mặc định. Chọn một tài khoản đã đăng ký của bạn, thay `YOUR_EMAIL@example.com` trong `SurveyApi/Database/003_first_admin.sql` bằng email đó, rồi chạy file một lần:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki
sqlcmd -S '.\SQLEXPRESS' -E -C -b -i SurveyApi/Database/003_first_admin.sql
```

Đăng xuất và đăng nhập lại để thấy màn hình Admin. File 003 là thao tác cấp quyền thủ công, không chạy như migration tự động. Các lần phân quyền sau thực hiện trong app.

API mới: POST /api/auth/change-password, POST /api/auth/logout, GET /api/members, GET /api/members/roles, PUT /api/members/{id}, DELETE /api/members/{id}.

## Phạm vi hiện tại

- Flutter: models, repositories, pages, services, local; học cách tổ chức từ trek_bikes_app.
- API: Controller, SiteProvider, Repository và Dapper; học từ WebApp.
- SQL Server: Roles, Members, Categories, Surveys, PlanItems, Campaigns, CampaignItems, Responses trong BusinessSurvey; không sửa database TrekBikes.
- SQLite phiên bản 2: lưu/đọc/xóa nháp câu trả lời theo tài khoản; giữ mã gửi khi thử lại. Chỉ nháp đã lưu mới dùng được offline; nháp không tự gửi nền.
- Logout gọi API thu hồi token và xóa token/nháp cục bộ; khi API không kết nối vẫn đăng xuất trên thiết bị và thông báo chưa thu hồi các phiên khác.
- App khôi phục hồ sơ cục bộ để vào nháp sau khi mở lại; quyền API vẫn do server kiểm tra. Khi token hết hạn hoặc quyền thay đổi, đăng nhập lại.
- Vai trò quản lý bằng gán Admin/Member; không tạo role tùy ý. Mẫu đã nằm trong chiến dịch không được sửa/xóa.
- Kế hoạch tương đương giỏ hàng; xác nhận tạo chiến dịch tương đương checkout; quản trị chiến dịch tương đương quản trị đơn hàng. Cần giải trình chức năng tương đương với giảng viên.
- Điểm cộng đơn giản: tìm kiếm chiến dịch theo tên/mã cho Member và Admin, lọc ngày tạo theo giờ Việt Nam, mẫu liên quan cùng danh mục có phân trang 10 mẫu/trang.
- Đã có ảnh danh mục: thêm, thay, bỏ ảnh và xóa file khi xóa danh mục. Ảnh PNG/JPEG tối đa 5 MB, không bắt buộc; danh mục cũ dùng biểu tượng mặc định. API danh mục thêm/sửa nhận multipart/form-data.
- Chưa làm xác thực email, quên mật khẩu, đăng nhập mạng xã hội và thanh toán. Thanh toán chỉ phù hợp nếu đề tài mở rộng bán gói khảo sát; phạm vi hiện tại không có thu tiền.
- Android cho phép HTTP để dùng máy chủ trong mạng nội bộ cả debug và release. Nếu triển khai qua Internet cần máy chủ HTTPS. Bản này chưa hỗ trợ SQLite trên web/Windows.
- Các script run-local.ps1 và run-phone.ps1 là lựa chọn phụ; không bắt buộc cho cách chạy trên.

## Tự kiểm thử

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\survey_app
flutter analyze
flutter test
flutter build apk --debug
```

Script `tests/full_api_check.ps1` cần một API kiểm thử localhost:5081 dùng database BusinessSurvey; chạy từ PowerShell bằng `powershell -ExecutionPolicy Bypass -File tests/full_api_check.ps1` tại `cuoiki`. Script tạo dữ liệu/tài khoản tạm rồi dọn đúng dữ liệu đó. Không dùng script kiểm thử trên môi trường có dữ liệu thật của doanh nghiệp.
