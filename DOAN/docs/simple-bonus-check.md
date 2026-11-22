# Điểm cộng đơn giản — 19/11/2026

Đã bổ sung tìm chiến dịch theo tên hoặc mã (`123` hoặc `#123`), lọc ngày tạo và mẫu khảo sát liên quan có phân trang. Không cần migration database mới. Controller → Repository/Dapper và Flutter Page → Repository giữ cách tổ chức hiện có.

## Kiểm tra trên điện thoại

1. Dừng API cũ bằng Ctrl+C, chạy lại `dotnet run` trong `cuoiki/SurveyApi`. Trong terminal Flutter nhấn `R`, hoặc chạy lại `flutter run` trong `cuoiki/survey_app`.
2. Member mở **Chiến dịch của tôi**: tìm một phần tên; tìm mã có/không có dấu #; thử từ khóa không tồn tại. Kết quả chỉ thuộc tài khoản đó. Xóa bộ lọc để trở về danh sách.
3. Chọn ngày **Từ/Đến**, nhấn **Áp dụng**. Hai ngày bằng nhau bao gồm toàn bộ ngày đó theo giờ Việt Nam. Có thể chỉ chọn một đầu. Khoảng đảo ngược phải báo lỗi. Thử kết hợp tên và ngày.
4. Admin mở **Quản lý chiến dịch**, làm lại bước 2–3: xem được tất cả chiến dịch phù hợp. **Khảo sát đang mở** vẫn chỉ có chiến dịch Active.
5. Với hơn 10 chiến dịch phù hợp, chuyển trang: giữ đúng bộ lọc; tìm mới và xóa bộ lọc trở về trang 1.
6. Mở chi tiết mẫu, cuộn cuối: **Mẫu khảo sát liên quan** chỉ có các mẫu khác cùng danh mục, mới nhất trước. Bấm một mẫu để xem chi tiết; quay lại được. Danh mục chỉ có một mẫu phải báo chưa có mẫu liên quan.
7. Với ít nhất 12 mẫu cùng danh mục: chi tiết một mẫu có 11 mẫu liên quan, trang đầu 10 và trang sau 1, không lặp mẫu và không chứa chính nó.
8. Xoay ngang, mở bàn phím ở ô tìm kiếm chiến dịch: nội dung cuộn được, không có sọc overflow. Dừng API rồi tải lại: hiện thông báo lỗi và có thể tải lại khi API chạy.

## Đối chiếu điểm cộng

| Phần tương đương bảng yêu cầu | Điểm thô dự kiến |
| --- | --- |
| Member tìm đơn hàng → tìm chiến dịch của mình | 0.25 |
| Admin tìm đơn hàng → tìm chiến dịch | 0.25 |
| Admin lọc đơn hàng theo ngày → lọc ngày tạo chiến dịch | 0.25 |
| Sản phẩm liên quan → mẫu cùng danh mục | 0.25 |
| Phân trang mẫu liên quan | 0.25 |

Tổng phần bổ sung này: 1.25 điểm thô theo cách quy đổi, không phải điểm cuối cùng hoặc cam kết giảng viên công nhận. Việc quy đổi chiến dịch cần giải trình theo đề tài khảo sát.

Để sau: ảnh danh mục (cần thêm schema, upload và xử lý thay/xóa ảnh); xác thực email/quên mật khẩu; đăng nhập Google/Facebook/Zalo. Thanh toán không có nghiệp vụ tương ứng trong ứng dụng khảo sát hiện tại, nên không thêm chỉ để lấy điểm. Nếu sau này bán gói dịch vụ khảo sát thì mới cân nhắc.

## Kết quả kiểm thử tự động

- API build: 0 lỗi, 0 warning.
- `flutter analyze`: không có vấn đề; `flutter test`: 7 kiểm thử đạt, gồm SQLite và hồi quy giao diện mở bàn phím ngang.
- `flutter build apk --debug`: build thành công. Chưa tự xác nhận toàn bộ chức năng mới bằng thao tác trên điện thoại.
- `tests/full_api_check.ps1`: 115 lượt kiểm tra đạt, gồm ranh giới đầu/cuối ngày Việt Nam, ngày đảo ngược, phân quyền, phân trang và không đưa chiến dịch chờ duyệt vào danh sách đang mở. Dùng tài khoản/dữ liệu tạm và dọn sau khi chạy.
- Kiểm thử giao diện trên máy không thay thế toàn bộ thao tác thực tế trên điện thoại; dùng các bước trên để xác nhận trải nghiệm.
