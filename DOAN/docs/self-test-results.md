# Kết quả tự kiểm thử bổ sung

Ngày: 19/11/2026. Không sử dụng mật khẩu của người dùng. Các tài khoản/danh mục/mẫu/chiến dịch kiểm thử API được tạo riêng và dọn sau kiểm tra.

## API và SQL Server

78 kiểm tra đạt trên bản API build mới, chạy riêng localhost:5081. Script: `cuoiki/tests/full_api_check.ps1`.

Ngoài luồng thông thường, đã kiểm tra:

- Hai yêu cầu checkout cùng mã gửi đồng thời chỉ tạo một chiến dịch.
- Hai yêu cầu gửi phản hồi cùng mã đồng thời chỉ ghi một phản hồi.
- Gửi lần thứ hai với mã khác bị từ chối.
- Câu chọn nhiều có đáp án trùng, lựa chọn không thuộc khảo sát và điểm ngoài 1–5 bị từ chối.
- Chiến dịch đóng không nhận phản hồi mới.
- Member không quản trị danh mục/mẫu/trạng thái; không đọc chiến dịch riêng và kết quả của người khác.
- Chặn xóa danh mục còn mẫu, mẫu đã triển khai và thành viên đã có dữ liệu liên quan.
- Đổi ảnh xóa file cũ; sửa không thay ảnh giữ file; xóa mẫu xóa file; ảnh giả bị từ chối.
- Phân trang 12 mẫu và tìm kiếm đúng kết quả.
- Mật khẩu hiện tại sai/mật khẩu mới giống cũ bị từ chối; đổi đúng vô hiệu token cũ; mật khẩu cũ không đăng nhập được.
- Role ngoài Admin/Member bị từ chối; khóa tài khoản chặn cả token cũ lẫn đăng nhập; mở khóa đăng nhập lại được; logout vô hiệu token.

API build: 0 warning/0 error. Flutter analyze: không có lỗi/cảnh báo. 5 test trên máy đạt: 2 SQLite và 3 widget.

## Điện thoại Android

Thiết bị MTN AN00 được adb nhận hợp lệ. Bộ chạy `flutter test integration_test/drafts_device_test.dart` đã build/cài nhưng không đi qua màn hình khởi động để chạy assertion. Đã dừng riêng bộ chạy này, không gỡ app hoặc xóa dữ liệu. Không tính bài đó là đạt.

Đã chạy bài SQLite Android độc lập tại `integration_test/android_sqlite_check.dart` để không phụ thuộc kết nối debugger. Bài dùng đúng file `business_survey_device_check.db`, không mở database chính; tự xóa file tạm sau kiểm tra. Đã đọc kết quả trực tiếp trên thiết bị: `passed: true`, 6 kiểm tra đạt:

1. Lưu nháp bằng SQLite Android thật.
2. Giữ mã gửi sau khi đóng/mở lại database.
3. Giữ nguyên văn bản, chọn một, chọn nhiều và thang điểm.
4. Cập nhật cùng nháp không sinh bản ghi trùng.
5. Xóa nháp một tài khoản không xóa tài khoản khác.
6. Xóa nháp cụ thể thành công.

Minh chứng: `evidence/android-sqlite-result.json` và `evidence/device-check.png`. Đã xác nhận database chính `business_survey.db` vẫn còn. Việc cài lại APK dùng install -r, không uninstall hoặc clear data.

Đã khôi phục thành công bản app thông thường trên điện thoại sau kiểm thử, không để lại entrypoint kiểm thử làm app chính. API kiểm thử cổng 5081 đã dừng; không dừng API của người dùng ở cổng 5080.

## Giới hạn

Các test đạt không chứng minh ứng dụng không còn lỗi. Chưa tự động xác nhận toàn bộ thao tác giao diện trên điện thoại, lựa chọn ảnh từ thư viện, xoay màn hình, chữ hệ thống lớn hoặc gián đoạn mạng đúng thời điểm giao dịch. Kết quả SQLite độc lập không thay thế kiểm thử toàn bộ màn hình trả lời.
