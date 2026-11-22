# Kết quả kiểm thử và cách trình bày

| Hình thức | Kết quả đã có | Nguồn và giới hạn |
| --- | --- | --- |
| Kiểm thử API | 134 lượt đạt | api-check-latest.log; script full_api_check.ps1 tạo và dọn dữ liệu tạm |
| Flutter tự động | 10 kiểm thử đạt | Bộ test trong survey_app/test; kết quả phiên kiểm tra gần nhất, chưa có log đầy đủ riêng trong thư mục này |
| Phân tích Dart | Không có vấn đề | flutter analyze trong phiên kiểm tra gần nhất |
| Build API | 0 lỗi, 0 warning | dotnet build trong phiên kiểm tra gần nhất |
| Build release | Thành công, khoảng 51 MB | apk-release-build.log |
| SQLite native trên Honor | 6 kiểm tra đạt | android-sqlite-result.json và device-check.png; đây là đợt kiểm tra kỹ thuật trước, không cộng vào 10 kiểm thử Flutter |
| Cài cập nhật release | Thành công, giữ phiên cục bộ | Minh chứng mở trang chủ trong tham_khao_cu; ảnh chụp lúc đang tải, không chứng minh tải dữ liệu thành công |
| Sử dụng Wi-Fi sau khi rút USB | Người dùng xác nhận ổn | Xác nhận thủ công trong phiên làm việc; cần ảnh minh chứng bản cuối nếu đưa vào báo cáo |

Các lượt API gồm phân quyền Member/Admin, danh mục/mẫu, ảnh mới/cũ, dọn file khi thất bại, tìm kiếm và phân trang, lọc ngày theo giờ Việt Nam, kế hoạch, checkout đồng thời, phản hồi đồng thời, thống kê, đổi mật khẩu, khóa tài khoản và đăng xuất. Không gọi 134 lượt là 134 màn hình hoặc khẳng định đã tự động kiểm thử toàn bộ trải nghiệm trên điện thoại.

Điền bảng kiem_thu_thuc_te.csv sau khi thao tác từng ca. Chưa điền sẵn Đạt cho các ca chưa có minh chứng riêng. Có thể ghi ngày, thiết bị và tên ảnh ở cột cuối.

Muốn chạy lại các kiểm thử: xem mã nguồn tests/full_api_check.ps1 và README của cuoiki. Script cần API kiểm thử riêng cổng 5081. Không chạy bừa trên database thật của doanh nghiệp; bộ tài nguyên không tự chạy các kiểm thử hoặc thay đổi database.
