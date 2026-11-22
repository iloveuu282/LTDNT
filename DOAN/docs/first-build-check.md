# Bản khởi tạo và xác thực

Ngày kiểm tra: 18/11/2026.

## Đã làm

- Tạo Flutter Android trong `cuoiki/survey_app`, API ASP.NET Core net10.0 trong `cuoiki/SurveyApi`.
- API dùng Dapper, SqlClient, BCrypt, JWT và cấu trúc Controller/Repository/SiteProvider học từ WebApp.
- Flutter dùng Member, MemberRepository, SessionHelper và các Page như cách tổ chức của trek_bikes_app, chia thư mục để dễ đọc.
- Tạo database riêng BusinessSurvey trên SQL Server Express bằng script 001_initial.sql; Roles, Members, Categories và ba danh mục mẫu.
- Đăng ký, đăng nhập, thông tin tài khoản, logout cục bộ. Đăng ký không nhận role từ client.
- Khởi tạo SQLite với bảng survey_drafts; chưa có giao diện sử dụng nháp.
- Hướng dẫn chạy tại `cuoiki/README.md`.

## Kết quả thực tế

| Kiểm tra | Kết quả |
| --- | --- |
| API build và chạy trên 127.0.0.1:5080 | Đạt |
| Health | 200, status ok |
| Đăng ký và ghi vào SQL Server | 201 |
| Đăng nhập rồi gọi me bằng JWT | Đạt, role Member |
| Đăng ký email trùng, body UTF-8 hợp lệ | 409 |
| Đăng nhập sai mật khẩu | 401 |
| Gọi me không có token | 401 |
| flutter analyze | No issues found |
| flutter test: chuyển từ đăng nhập sang đăng ký | Đạt |
| SQLite trên Android và logout bằng thao tác trên máy | Chưa kiểm tra, không có thiết bị Android kết nối |

Tài khoản demo kiểm tra API: `demo.a7c456b4@example.com`, mật khẩu `Demo@123456`. Chỉ dùng cho dữ liệu local đồ án.

Ngày 19/11/2026: đã cách ly cache transforms lỗi của dự án (giữ bản sao), build APK thành công. Sau khi đơn giản hóa cấu hình chạy, build API đạt 0 warning/0 error và APK debug tiếp tục build thành công. Điện thoại MTN AN00 đã được adb nhận với trạng thái device; chưa xác nhận thao tác đăng nhập trên giao diện điện thoại.

Cách chạy chính đã đổi thành `dotnet run` trong SurveyApi rồi `flutter run` trong survey_app. API tự thiết lập chuyển tiếp USB khi build Debug trên Windows, tự tạo JWT key local trong Development; Flutter dùng localhost:5080 và wrapper tự chọn cache riêng. Chi tiết tại `cuoiki/README.md`.

Logout hiện chỉ xóa token trên thiết bị và nháp của tài khoản; chưa thu hồi JWT phía server. Chưa làm tự khôi phục phiên, đổi mật khẩu và quản trị member/role. Không xem bản này là hoàn tất toàn bộ nhóm xác thực.
