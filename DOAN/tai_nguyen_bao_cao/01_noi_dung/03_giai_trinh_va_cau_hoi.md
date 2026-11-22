# Giải trình chức năng và câu hỏi thường gặp

## Cách quy đổi nghiệp vụ

| Tiêu chí gốc | Chức năng trong đề tài | Lý do tương đương |
| --- | --- | --- |
| Sản phẩm | Mẫu khảo sát | Đối tượng được phân loại, có ảnh, danh sách, tìm kiếm và chi tiết |
| Danh mục sản phẩm | Danh mục khảo sát | Phân loại mẫu theo mục đích khách hàng, nhân sự hoặc thị trường |
| Giỏ hàng | Kế hoạch khảo sát | Tập hợp các mẫu trước khi triển khai, có thêm/sửa/xóa và badge |
| Số lượng sản phẩm | Số phản hồi mục tiêu | Chỉ tiêu thu thập cho từng mẫu |
| Checkout | Tạo chiến dịch | Xác nhận kế hoạch để lưu chiến dịch và chi tiết |
| Đơn hàng | Chiến dịch khảo sát | Có chủ sở hữu, chi tiết, trạng thái, tìm kiếm và lọc ngày |
| Sản phẩm liên quan | Mẫu cùng danh mục | Giúp lựa chọn các mẫu có cùng mục đích |

Đây là giải trình đề nghị công nhận chức năng tương đương, không phải cam kết số điểm. Không gọi các giao dịch trong hệ thống là mua bán khi trình bày nghiệp vụ.

## Tại sao vẫn có kế hoạch khảo sát

Doanh nghiệp có thể cần dùng nhiều mẫu trong một đợt thu thập ý kiến. Kế hoạch giúp chọn các mẫu và chỉ tiêu trước khi tạo chiến dịch. Đây là một bước chuẩn bị nghiệp vụ, không phải giỏ mua hàng có giá và tiền thanh toán.

## Tại sao không làm thanh toán

Hệ thống hiện không bán hàng hoặc bán gói khảo sát và không có khoản tiền cần thu. Việc thêm VNPayment/VietQR không có đầu vào nghiệp vụ phù hợp. Chỉ nên triển khai nếu mở rộng dịch vụ có thu phí.

## Member có quá nhiều quyền hay không

Member trong mô hình này là người dùng hệ thống của doanh nghiệp: có thể tạo chiến dịch, tham gia và xem kết quả chiến dịch mình tạo. Member không quản trị thành viên, danh mục, mẫu hoặc trạng thái. Nếu chỉ dành Member cho khách trả lời thì cần tách thêm vai trò trong một phiên bản mở rộng.

## SQLite và SQL Server khác nhau ở đâu

SQL Server là nguồn dữ liệu tập trung cho nghiệp vụ online. SQLite chỉ giữ bản nháp trên điện thoại. Token và cấu hình kết nối dùng Secure Storage. Không mô tả app là đã đồng bộ toàn bộ dữ liệu hoặc tự gửi nền vì chưa có chức năng đó.

## Tại sao mẫu đã triển khai không được sửa hoặc xóa

Sửa câu hỏi hoặc lựa chọn sau khi có chiến dịch có thể làm sai ý nghĩa các câu trả lời cũ. Hệ thống khóa mẫu khi đã nằm trong chiến dịch để bảo toàn lịch sử. Muốn khảo sát nội dung khác thì tạo mẫu mới.

## Tránh gửi trùng bằng cách nào

Checkout dùng RequestId duy nhất theo tài khoản. Phản hồi dùng SubmissionId và ràng buộc một người trả lời một lần trên mỗi CampaignItem. API dùng transaction và ràng buộc database để xử lý cả các yêu cầu đồng thời; không chỉ khóa nút trên giao diện.

## Rút dây có làm app ngừng chạy không

Không. Bản release chạy độc lập và gọi API qua Wi-Fi. Máy tính chạy máy chủ vẫn phải bật. Khi tắt mạng hoặc máy chủ dừng, nháp đã lưu vẫn dùng được, còn gửi phản hồi và quản trị cần kết nối.

## Phong cách tổ chức mã nguồn

Flutter học cách phân chia models, repositories, pages và services từ trek_bikes_app. API học cấu trúc Controller, SiteProvider và Repository từ WebApp; dùng Dapper để truy vấn SQL rõ ràng. Nội dung nghiệp vụ khảo sát, câu hỏi, chiến dịch và nháp được xây dựng theo đề tài. Không đưa mật khẩu hoặc khóa bí mật vào phần mã minh họa.

## Các phần còn lại

Email xác thực và quên mật khẩu: mức trung bình, cần dịch vụ email và mã dùng một lần có thời hạn. Đăng nhập mạng xã hội: cần tài khoản nhà cung cấp, OAuth và cấu hình ứng dụng. Thanh toán: chưa phù hợp phạm vi. Ảnh danh mục đã hoàn thành, không còn thuộc danh sách chưa làm.

## Trình tự trình bày khi cần

Đăng nhập Admin → danh mục/ảnh → mẫu/câu hỏi → Member chọn kế hoạch và tạo chiến dịch → Admin mở → người tham gia trả lời/lưu nháp → chủ chiến dịch xem kết quả. Có thể dùng ảnh để trình bày các bước thay vì phải luyện demo riêng. Không xóa dữ liệu thật để tạo tình huống lỗi.
