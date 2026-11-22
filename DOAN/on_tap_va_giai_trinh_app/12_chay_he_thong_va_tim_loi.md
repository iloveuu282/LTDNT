# Chạy hệ thống, kiểm thử và tìm lỗi

## Chạy bình thường

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\SurveyApi
dotnet run
```

API dùng SQL Server đã chuẩn bị script và nghe cổng 5080. LaunchSettings Development lắng nghe 0.0.0.0 để truy cập cả localhost và mạng nội bộ. Kết nối máy chủ trong app nhập URL gốc, ví dụ http://192.168.1.7:5080, không thêm /api. IP là ví dụ hiện tại, có thể thay đổi theo router/mạng.

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\survey_app
flutter run
```

Đây là lệnh phát triển. Bản release đã cài mở trực tiếp từ icon, không cần terminal Flutter. Rút dây vẫn dùng online nếu điện thoại/máy tính cùng mạng và API/SQL Server chạy. Máy chủ tắt thì chỉ làm việc với nháp đã lưu.

Để cho phép Wi-Fi lần đầu nếu Windows chặn, chạy enable-wifi.ps1 bằng PowerShell Administrator. Script mở riêng TCP 5080 cho LocalSubnet, không tắt firewall. Đọc cấu hình tại [launchSettings.json](<../cuoiki/SurveyApi/Properties/launchSettings.json>) — dòng 1 và [enable-wifi.ps1](<../cuoiki/enable-wifi.ps1>) — dòng 1.

## Khi muốn build hoặc kiểm tra code

```powershell
flutter analyze
flutter test
flutter build apk --release
```

Lệnh build trên mặc định URL phát triển localhost nếu không truyền API_URL; app vẫn ưu tiên server_url đã lưu. Muốn APK mới mặc định Wi-Fi thì truyền --dart-define=API_URL=http://<IPv4-máy-chủ>:5080. Bản release dùng chữ ký debug hiện tại cho cập nhật nội bộ; không phải cấu hình phát hành cửa hàng hoàn chỉnh.

## Các lỗi thường hỏi

| Hiện tượng | Kiểm tra ở đâu |
| --- | --- |
| Không kết nối máy chủ | API còn chạy, IPv4 đúng, cùng Wi-Fi, cổng 5080, firewall, router không cô lập thiết bị; thử /api/health |
| Health OK nhưng không tải được dữ liệu | Kiểm tra kết nối SQL Server và log API; health chỉ báo web API phản hồi |
| 401 sau đổi quyền/mật khẩu | Token cũ bị thu hồi hoặc hết hạn; đăng nhập lại, không sửa app để bỏ xác thực |
| 403 | Không có vai trò hoặc quyền sở hữu cần thiết |
| Nút sửa mẫu bị mờ | Mẫu có IsUsed vì đã nằm trong CampaignItems; đây là ràng buộc lịch sử |
| Không thấy nút Trả lời | Chưa Active, đã trả lời hoặc đủ mục tiêu |
| Gửi lại nháp sau khi chiến dịch đóng bị chặn | Quy tắc server vẫn áp dụng cho nháp cũ; offline không giữ quyền gửi mãi |
| Chưa thấy ảnh mới | API phải là bản mới, URL hiện tại đúng; kiểm tra file/đường dẫn và lỗi upload |
| Không có mẫu liên quan | Danh mục chỉ có mẫu hiện tại hoặc chưa tải được phần liên quan |
| Lỗi database cột ImagePath | Máy mới chưa chạy 005_category_images.sql |

## Kết quả kiểm thử đã có

- API: 134 lượt kiểm tra đạt, có log trong bộ tài nguyên báo cáo. Script [full_api_check.ps1](<../cuoiki/tests/full_api_check.ps1>) — dòng 1 dùng API kiểm thử riêng cổng 5081 và tạo/dọn dữ liệu tạm.
- Flutter: 10 kiểm thử gồm SQLite, phân quyền giao diện, validation mật khẩu, mở đăng ký, layout ngang và cấu hình máy chủ; xem survey_app/test.
- Android SQLite đợt trước: 6 kiểm tra native, tách riêng với 10 kiểm thử Flutter.
- Bản release build/cài cập nhật thành công; người dùng xác nhận hoạt động qua Wi-Fi ổn. Không đồng nghĩa đã đo tải lớn hoặc test mọi tổ hợp thiết bị.

Không cần tự chạy lại toàn bộ test chỉ để ôn tài liệu. Nếu chạy integration_test lên điện thoại, không dùng luồng có thể gỡ cài đặt/xóa dữ liệu thật; ưu tiên đọc code hoặc thiết bị/dữ liệu thử riêng.
