# Bản hoàn thiện và sử dụng không cần dây USB

## Những phần đã cập nhật

- Danh mục có ảnh đại diện tùy chọn: chọn ảnh trên điện thoại, xem trước, thêm, thay ảnh, bỏ ảnh và giữ lại ảnh cũ trước khi lưu. Đổi ảnh thành công mới xóa ảnh cũ. Xóa danh mục còn mẫu bị chặn và giữ nguyên ảnh. Lưu thất bại do trùng tên hoặc danh mục không tồn tại sẽ dọn ảnh mới.
- Ảnh danh mục xuất hiện trong quản trị và bộ chọn danh mục ở trang chủ. Danh mục cũ không ảnh vẫn dùng được với biểu tượng thư mục.
- Thay biểu tượng mua hàng bằng kế hoạch khảo sát; đổi tên hiển thị Android thành Khảo sát doanh nghiệp và icon ứng dụng thành bảng khảo sát. Giữ tên package để cập nhật ứng dụng mà không xóa tài khoản hoặc nháp.
- Nhãn giao diện dùng Bản nháp và Lưu nháp; bỏ tên SQLite/API trong các thông báo thông thường. Các công cụ kiểm thử nằm ngoài luồng sử dụng; không xóa dữ liệu khảo sát hoặc tài khoản người dùng đã tạo.
- Kết nối máy chủ có ở màn hình đăng nhập và trang chủ. Địa chỉ lưu trên điện thoại và dùng cho tất cả lời gọi, kể cả đăng nhập và upload. Kiểm tra kết nối trước khi lưu; không gửi token khi kiểm tra health.

## Chuẩn bị trên máy tính

Database máy hiện tại đã áp dụng `SurveyApi/Database/005_category_images.sql`. Máy mới chạy 001, 002, 004 rồi 005; không chạy 003 nếu không định cấp quyền Admin thủ công.

1. Dừng API cũ bằng Ctrl+C và chạy lại `dotnet run` trong `E:\Zhoc\LTDNT\DOAN\cuoiki\SurveyApi`. Máy chủ mới lắng nghe `0.0.0.0:5080`, không còn chỉ localhost.
2. Mở PowerShell bằng **Run as administrator**, chạy một lần:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File E:\Zhoc\LTDNT\DOAN\cuoiki\enable-wifi.ps1
```

Quy tắc chỉ cho thiết bị cùng subnet truy cập TCP 5080; không tắt tường lửa. Phiên công cụ không có quyền Administrator nên chưa thêm được quy tắc này. Nếu muốn gỡ sau khi ngừng dùng, chạy PowerShell Administrator: `Remove-NetFirewallRule -Name BusinessSurvey-API-WiFi-5080`.

## Chạy app sau khi rút dây

1. Cài APK release hoặc chạy `flutter run --release` để cài bản chạy độc lập. Cập nhật bằng `adb install -r` giữ dữ liệu; không gỡ cài đặt và không xóa dữ liệu app.
2. Điện thoại và máy tính dùng cùng mạng Wi-Fi. Trong **Kết nối máy chủ**, nhập địa chỉ IPv4 máy tính, ví dụ hiện tại là `http://192.168.1.7:5080`. Chọn **Kiểm tra kết nối**, sau đó **Lưu và sử dụng**. Có thể mở `http://192.168.1.7:5080/api/health` bằng trình duyệt điện thoại để kiểm tra trước.
3. Rút USB, mở app từ icon trên điện thoại. Thử tải danh sách, đăng nhập, mở ảnh và gửi phản hồi. Không cần terminal Flutter tiếp tục chạy.
4. Máy tính vẫn phải bật, SQL Server và API vẫn chạy. Điện thoại dùng 4G hoặc ở mạng khác sẽ không truy cập địa chỉ Wi-Fi nội bộ này. Muốn dùng từ bất kỳ đâu cần triển khai API lên máy chủ có HTTPS, ngoài phạm vi bản nội bộ hiện tại.
5. Nếu IP máy tính đổi khi đổi mạng hoặc router cấp lại địa chỉ, cập nhật trong app; không cần build lại. Khi dùng USB trở lại, chọn Dùng kết nối USB và lưu sau khi máy chủ/adb reverse đã sẵn sàng.
6. Nếu không kết nối được dù đã cho phép cổng, kiểm tra hai thiết bị cùng mạng và router không bật cô lập thiết bị/mạng khách.

## Khi không có mạng

App giữ phiên cục bộ và mở được mục Bản nháp. Chỉ các bản nháp đã lưu mới đọc/sửa được offline. Không thể đăng nhập mới, quản trị hoặc gửi phản hồi khi máy chủ không truy cập được. Nháp không tự gửi nền; mở và bấm Gửi phản hồi khi có kết nối trở lại.

## Kiểm tra ảnh danh mục trên điện thoại

1. Admin mở Danh mục → thêm danh mục, chọn PNG/JPEG, xem trước rồi lưu. Kiểm tra ảnh trong danh sách và bộ chọn trang chủ.
2. Sửa mô tả mà không chọn ảnh: ảnh không đổi. Chọn ảnh khác và lưu: ảnh mới xuất hiện.
3. Bỏ ảnh rồi lưu: trở về biểu tượng mặc định. Nếu chưa lưu có thể chọn Giữ ảnh cũ hoặc Hủy.
4. Thử lưu tên trùng khi đang thay ảnh: báo lỗi, ảnh cũ vẫn còn sau khi đóng và tải lại.
5. Xóa danh mục trống có ảnh: danh mục và ảnh được xóa. Xóa danh mục còn mẫu: bị chặn và ảnh vẫn còn.
6. Member không có chức năng quản trị danh mục, chỉ xem và lọc mẫu theo danh mục.

## Kiểm chứng

- API build: không lỗi hoặc warning.
- Bộ API: 134 lượt kiểm tra đạt, dùng và dọn dữ liệu tạm.
- Flutter: 10 kiểm thử đạt; flutter analyze không có vấn đề.
- APK release build thành công, khoảng 51 MB, không có cờ debuggable. File: `cuoiki/survey_app/build/app/outputs/flutter-apk/app-release.apk`. Bản hiện tại mặc định địa chỉ Wi-Fi `http://192.168.1.7:5080`; có thể đổi trong app.
- Đã cài cập nhật APK release bằng `adb install -r` trên điện thoại Honor đang kết nối, mở được trang chủ và giữ hồ sơ đăng nhập cũ. Đã xác minh tên app, icon mới, quyền Internet và HTTP nội bộ trong APK. Chưa xác nhận kết nối Wi-Fi vì API người dùng vẫn là phiên cũ chỉ lắng nghe localhost và quyền tường lửa cần Administrator.
- Còn cần xác nhận trực tiếp trên điện thoại sau khi cấp quyền tường lửa và khởi động lại API mới; kết quả kiểm thử trên máy không chứng minh đường truyền Wi-Fi giữa hai thiết bị.

Bản APK release dùng chữ ký debug hiện tại để cập nhật app đồ án đã cài. Đây là bản cài nội bộ; phát hành cửa hàng cần cấu hình khóa ký riêng.
