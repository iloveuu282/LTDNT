# Bản đầy đủ chức năng bắt buộc

Ngày thực hiện: 19/11/2026.

## Phạm vi đã code

Flutter/Dart + SQLite trên điện thoại; REST API ASP.NET Core 10 + SQL Server, truy cập qua Dapper. Không thay đổi mã nguồn hai dự án mẫu. Toàn bộ mã nguồn ở DOAN/cuoiki.

1. Đăng ký, đăng nhập, đổi mật khẩu, logout, quản lý thành viên, gán Admin/Member, khóa/mở và kiểm tra quyền ở API.
2. Danh mục: danh sách/thêm/sửa/xóa, chặn xóa khi còn mẫu.
3. Mẫu khảo sát: danh mục, ảnh, câu hỏi, thêm/sửa/xóa, phân trang; thay/xóa ảnh kèm theo; chặn sửa/xóa mẫu đã triển khai.
4. Trang chủ: danh mục, mẫu mới nhất, tìm kiếm, lọc theo danh mục, phân trang và chi tiết.
5. Kế hoạch: thêm mẫu, badge đếm mẫu, danh sách, đổi chỉ tiêu, bỏ mẫu, xác nhận tạo chiến dịch và xem chi tiết.
6. Admin xem chiến dịch và cập nhật trạng thái. Member xem chiến dịch của mình và danh sách chiến dịch đang mở.
7. Trả lời bốn loại câu hỏi; lưu nháp SQLite, mở lại sau khi đóng app, gửi chủ động khi có mạng, chống gửi trùng và kiểm tra đủ chỉ tiêu/trạng thái.
8. Thống kê cơ bản cho chủ chiến dịch và Admin.

Các vai trò cố định Admin/Member. Bản này phục vụ một doanh nghiệp, không làm quản lý nhiều doanh nghiệp hoặc tạo role tùy ý. Kế hoạch/chiến dịch là phương án quy đổi từ giỏ hàng/đơn hàng, cần giảng viên chấp nhận khi chấm điểm.

## Tổ chức mã nguồn

- Flutter: models chứa dữ liệu/fromMap; repositories gọi HTTP; pages là giao diện; ApiService và SessionHelper dùng chung; LocalDatabase quản lý SQLite; widgets/common dùng cho thông báo, xác nhận và phân trang.
- API: Models gồm model và Repository; SiteProvider cấp repository; Controllers kiểm tra đầu vào/quyền và trả HTTP; ImageService lưu/xóa ảnh.
- Câu hỏi và câu trả lời lưu JSON trong SQL Server để tránh nhiều bảng trung gian ở đồ án nhỏ. CampaignItems, PlanItems và Responses có khóa ngoại/ràng buộc chống trùng.
- Khi mẫu có trong chiến dịch, khóa sửa nội dung thay vì xây dựng hệ thống phiên bản phức tạp.

## Kiểm tra đã chạy

- API build đạt 0 warning/0 error trước kiểm thử luồng hoàn chỉnh.
- Script `cuoiki/tests/full_api_check.ps1`: ban đầu 62 kiểm tra đạt, lần bổ sung mở rộng thành 78 kiểm tra đạt trên API localhost:5081 với database SQL Server thực. Dữ liệu và ảnh thử được dọn sau kiểm tra; tài khoản thật giữ nguyên. Xem `self-test-results.md`.
- Kiểm tra gồm upload bắt buộc, từ chối ảnh giả, xóa ảnh cũ khi thay, giữ ảnh khi không thay, xóa ảnh kèm mẫu, chặn xóa danh mục còn mẫu, phân trang 12 mẫu, tìm kiếm, kế hoạch riêng, chỉ tiêu, checkout idempotent, trạng thái, quyền, xác thực phản hồi, chống gửi trùng và kết quả biết trước.
- SQLite được kiểm tra bằng engine thật qua sqflite_common_ffi chỉ trong dev dependencies: giữ nháp sau đóng/mở database, cập nhật không trùng, tách tài khoản, xóa đúng tài khoản, nâng schema v1→v2 không mất dữ liệu. Đây là kiểm thử trên máy tính, chưa thay thế kiểm tra SQLite trên điện thoại.
- Widget test: menu Admin/Member, xác nhận mật khẩu không khớp, chuyển sang đăng ký.
- Kết quả cuối: flutter analyze không có lỗi/cảnh báo; 5 test đạt (2 SQLite và 3 widget); APK debug build thành công tại `cuoiki/survey_app/build/app/outputs/flutter-apk/app-debug.apk`.
- Build Android ban đầu vướng cache incremental Kotlin của image_picker_android; đã tắt incremental Kotlin và dùng compiler in-process trong gradle.properties của riêng đồ án, clean và build thành công. Không thay cấu hình hai folder mẫu.

## Chưa xác nhận

Toàn bộ màn hình mới và bộ chọn ảnh cần người dùng chạy checklist trên điện thoại. Việc build APK hoặc kiểm thử API không đồng nghĩa đã hoàn tất kiểm thử giao diện trên điện thoại.

## Hướng dẫn người dùng

Xem `full-test-checklist.md`. Cách chạy chính giữ nguyên `dotnet run` và `flutter run`. Migration 004 đã áp dụng trên máy hiện tại; giữ tài khoản và quyền Admin đã có. Chưa thực hiện các điểm cộng tùy chọn.
