# Giải trình yêu cầu và nghiệp vụ

## Nhóm đáp ứng trực tiếp

Flutter Dart, SQLite trên điện thoại, REST API C# .NET 10 và SQL Server là công nghệ bắt buộc đã dùng. Đăng ký, đăng nhập, đổi mật khẩu, thành viên, gán Admin/Member, logout và phân quyền được thực hiện trực tiếp. Không nói quản lý role có tạo/xóa role tùy ý: hiện chỉ gán hai vai trò cố định.

## Nhóm chuyển đổi nghiệp vụ

| Trong yêu cầu | Trong app | Điểm giống về chức năng |
| --- | --- | --- |
| Sản phẩm | Mẫu khảo sát | CRUD, ảnh, phân loại, chi tiết và phân trang |
| Danh mục sản phẩm | Danh mục khảo sát | CRUD, ảnh và chặn xóa khi có mẫu |
| Giỏ hàng | Kế hoạch khảo sát | Chọn mẫu, sửa chỉ tiêu, bỏ mẫu và badge |
| Số lượng | Số phản hồi mục tiêu | Giá trị cập nhật theo mỗi mẫu |
| Checkout | Xác nhận tạo chiến dịch | Tạo đầu mục/chi tiết và xóa kế hoạch trong transaction |
| Đơn hàng | Chiến dịch | Chủ sở hữu, chi tiết, trạng thái, tìm kiếm/lọc ngày |
| Sản phẩm liên quan | Mẫu cùng danh mục | Liên quan theo danh mục, có phân trang |

Điều quan trọng là doanh nghiệp cần chọn một hoặc nhiều mẫu và chỉ tiêu trước mỗi đợt khảo sát. Không có giá, tổng tiền hoặc thu tiền trong kế hoạch. Giảng viên cần xem xét công nhận tương đương; không tự quy đổi thành điểm cuối cùng.

## Các chức năng riêng của đề tài

1. Câu hỏi text/single/multiple/rating; có bắt buộc/tùy chọn.
2. Người dùng tham gia và gửi phản hồi.
3. Kiểm tra đáp án theo kiểu, giới hạn và lựa chọn của mẫu.
4. Một tài khoản trả lời một lần cho mỗi mẫu trong một chiến dịch; giới hạn chỉ tiêu.
5. Thống kê văn bản, lựa chọn và điểm đánh giá trung bình.
6. Lưu nháp, mở lại offline và giữ mã gửi khi retry.
7. Chỉ chủ chiến dịch/Admin xem kết quả.

SQLite là yêu cầu công nghệ, còn cách dùng SQLite để lưu nháp là phần nghiệp vụ đề tài. Chống gửi trùng, transaction và cấu hình Wi-Fi là xử lý hỗ trợ kỹ thuật, không tự coi mỗi xử lý là một mục cộng điểm riêng.

## Điểm cộng đã làm và phần chưa làm

Đã làm: ảnh danh mục; kiểm tra mẫu có trong chiến dịch trước xóa; phân trang theo danh mục và tìm kiếm; mẫu liên quan có phân trang; tìm chiến dịch cho Member/Admin và lọc ngày. Bảng chi tiết nằm ở phu_luc/yeu_cau_va_tien_do.md.

Chưa làm: xác thực email, quên mật khẩu, đăng nhập Google/Facebook/Zalo và thanh toán. Email/mạng xã hội cần dịch vụ và cấu hình ngoài. Thanh toán chưa phù hợp vì không có nghiệp vụ thu tiền; chỉ cân nhắc nếu bán gói khảo sát. Không cần xây nghiệp vụ mua bán chỉ để giải thích yêu cầu.

Tổng điểm nhóm trang chủ trong đề và tổng các dòng bắt buộc có chênh lệch; giữ số đề và hỏi cách tính thay vì tự sửa. Không khẳng định chắc chắn đạt một mức điểm trước khi giảng viên xem phần tương đương.
