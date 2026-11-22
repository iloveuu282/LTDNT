# Đối chiếu yêu cầu và tiến độ

Cập nhật sau khi hoàn thành ảnh danh mục và chạy Wi-Fi. Điểm giữ theo bảng yêu cầu, không tự quy thành điểm cuối cùng. Các phần chuyển đổi nghiệp vụ cần giảng viên công nhận.

| Chức năng | Yêu cầu | Điểm theo đề | Trạng thái và giải trình |
| --- | --- | --- | --- |
| Công nghệ bắt buộc | Bắt buộc | Điều kiện | Đã đáp ứng các công nghệ yêu cầu. |
| Flutter sử dụng ngôn ngữ Dart | Bắt buộc | — | Đã hoàn thành. Ứng dụng điện thoại trong cuoiki/survey_app. |
| SQLite lưu trữ trên điện thoại | Bắt buộc | — | Đã hoàn thành. Lưu, đọc, sửa và xóa nháp trả lời theo tài khoản; giữ nháp khi mất kết nối. |
| REST API C# ASP.NET Core 10 và SQL Server | Bắt buộc | — | Đã hoàn thành. SurveyApi dùng net10.0; SQL Server lưu tài khoản, danh mục, mẫu khảo sát, chiến dịch và phản hồi. |
| Nhóm xác thực người dùng | Nhóm bắt buộc | 2.25 + 0.75 API | Đã có các chức năng bắt buộc và xác thực qua API. |
| Đăng ký người dùng | Bắt buộc | 0.25 | Đã hoàn thành. Đăng ký qua API; tài khoản mới mặc định Member. |
| Đăng nhập | Bắt buộc | 0.25 | Đã hoàn thành. Đăng nhập bằng email và mật khẩu; API cấp JWT. |
| Đổi mật khẩu | Bắt buộc | 0.25 | Đã hoàn thành. Kiểm tra mật khẩu hiện tại; thu hồi token cũ sau khi đổi thành công. |
| Quản lý member | Bắt buộc | 0.25 | Đã hoàn thành. Admin xem danh sách, sửa họ tên, khóa/mở và xóa tài khoản chưa có dữ liệu liên quan. |
| Quản lý role người dùng | Bắt buộc | 0.5 | Đã hoàn thành. Admin gán vai trò Admin hoặc Member. Hai vai trò cố định; không tạo role tùy ý. |
| Chức năng thoát logout | Bắt buộc | 0.25 | Đã hoàn thành. Đăng xuất và xóa dữ liệu phiên cục bộ; gọi API thu hồi token khi có kết nối. |
| Phân quyền Member và Admin | Bắt buộc | 0.5 | Đã hoàn thành. Ẩn chức năng quản trị với Member; API kiểm tra quyền cho các thao tác quản trị. |
| Xác thực người dùng qua email | Điểm cộng | 0.5 | Chưa làm. Để sau vì cần dịch vụ gửi email, mã xác thực, thời hạn và xử lý gửi lại; mức trung bình. |
| Quên mật khẩu | Điểm cộng | 0.5 | Chưa làm. Để sau vì cần kênh email và luồng khôi phục an toàn, mã dùng một lần có hạn; mức trung bình. |
| Đăng nhập bằng Gmail Google, Facebook, Zalo | Điểm cộng | 3 × 0.5 | Chưa làm. Để sau vì cần đăng ký ứng dụng với từng nhà cung cấp, OAuth và cấu hình Android; mức trung bình đến khó. |
| Quản lý danh mục dành cho Admin | Nhóm bắt buộc | 1.25 + 0.5 API | Danh mục dùng để phân loại mẫu khảo sát; các thao tác qua API. |
| Hiển thị danh mục | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Danh sách danh mục khảo sát. |
| Thêm danh mục | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Admin thêm danh mục khảo sát. |
| Xóa danh mục | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Admin xóa danh mục trống. |
| Kiểm tra danh mục có sản phẩm trước khi xóa | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Chặn xóa danh mục còn chứa mẫu khảo sát. |
| Sửa danh mục | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Admin sửa tên và mô tả danh mục. |
| Upload ảnh danh mục khi thêm, xóa và sửa | Điểm cộng | 0.75 | Đã hoàn thành. Upload khi thêm, thay ảnh thì xóa ảnh cũ, bỏ ảnh và xóa file khi xóa danh mục. Danh mục còn mẫu bị chặn xóa và giữ ảnh; lỗi lưu dọn ảnh mới. |
| Quản lý sản phẩm theo từng danh mục | Nhóm bắt buộc | 2 + 0.75 API | Sản phẩm được quy đổi thành mẫu khảo sát; có upload ảnh và phân trang qua API. |
| Hiển thị sản phẩm có phân trang | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Danh sách mẫu khảo sát theo danh mục, 10 mẫu mỗi trang. |
| Thêm sản phẩm có upload hình ảnh | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Admin thêm mẫu, câu hỏi và ảnh bắt buộc; kiểm tra định dạng PNG/JPEG và dung lượng. |
| Xóa sản phẩm và xóa ảnh kèm theo | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Xóa mẫu chưa dùng và ảnh của mẫu đó. |
| Sửa sản phẩm và xóa ảnh cũ khi thay ảnh mới | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Sửa mẫu chưa triển khai; thay ảnh thì xóa ảnh cũ. Mẫu đã nằm trong chiến dịch bị khóa sửa. |
| Kiểm tra sản phẩm có trong đơn hàng trước khi xóa | Điểm cộng | 0.5 | Đã hoàn thành tương đương. Chặn xóa mẫu đã nằm trong chiến dịch để bảo toàn lịch sử và phản hồi. |
| Hiển thị sản phẩm trên trang chủ | Nhóm bắt buộc | 1.75 + 0.5 API | Trang chủ hiển thị danh mục và mẫu khảo sát qua API. Giữ nguyên tổng nhóm theo đề bài. |
| Hiển thị danh mục sản phẩm | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Hiển thị danh mục khảo sát để chọn lọc. |
| Hiển thị sản phẩm mới nhất có phân trang | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Mẫu mới nhất trước, 10 mẫu mỗi trang. |
| Hiển thị sản phẩm theo danh mục | Bắt buộc | 0.25; +0.25 phân trang | Đã hoàn thành tương đương. Lọc mẫu theo danh mục và phân trang; đã có phần phân trang cộng thêm. |
| Tìm kiếm sản phẩm | Bắt buộc | 0.25; +0.25 phân trang | Đã hoàn thành tương đương. Tìm theo tên mẫu khảo sát và phân trang; đã có phần phân trang cộng thêm. |
| Hiển thị chi tiết sản phẩm | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Chi tiết tên mẫu, danh mục, mô tả, ảnh và nội dung câu hỏi. |
| Hiển thị sản phẩm liên quan | Điểm cộng | 0.25; +0.25 phân trang | Đã hoàn thành tương đương. Các mẫu khác cùng danh mục, loại chính mẫu đang xem, có phân trang 10 mẫu mỗi trang. |
| Quản lý giỏ hàng | Nhóm bắt buộc | 2.5 + 1 API | Giỏ hàng quy đổi thành kế hoạch khảo sát; đơn hàng quy đổi thành chiến dịch. |
| Đặt button thêm giỏ hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Có nút Thêm vào kế hoạch trong chi tiết mẫu. |
| Thêm sản phẩm vào giỏ hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Thêm mẫu vào kế hoạch; một mẫu không bị thêm trùng. |
| Hiển thị số lượng sản phẩm trên icon giỏ hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Badge hiển thị số mẫu khác nhau trong kế hoạch, không phải tổng số phản hồi mục tiêu. |
| Hiển thị giỏ hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Màn hình kế hoạch hiển thị mẫu và số phản hồi mục tiêu. |
| Cập nhật số lượng trên giỏ hàng | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Thay số phản hồi mục tiêu của từng mẫu trong kế hoạch. |
| Xóa sản phẩm trên giỏ hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Xóa mẫu khỏi kế hoạch của tài khoản hiện tại. |
| Chức năng đặt hàng checkout | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Xác nhận tạo chiến dịch từ kế hoạch, lưu các mẫu và mục tiêu rồi làm trống kế hoạch; chống tạo trùng khi gửi lại. |
| Hiển thị chi tiết đơn hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Chi tiết chiến dịch gồm các mẫu, mục tiêu, số phản hồi và trạng thái. |
| Tìm kiếm đơn hàng | Điểm cộng | 0.25 | Đã hoàn thành tương đương. Member tìm chiến dịch của mình theo tên hoặc mã, có phân trang. |
| Thanh toán online VNPayment, VietQR | Điểm cộng | 2 × 0.5 | Chưa làm. Không phù hợp phạm vi hiện tại: ứng dụng tổ chức khảo sát, không bán hàng hoặc thu tiền. Chỉ cân nhắc khi có nghiệp vụ bán gói dịch vụ khảo sát; tích hợp thanh toán cũng có độ phức tạp cao hơn. |
| Quản lý đơn hàng dành cho Admin | Nhóm bắt buộc | 0.75 + 0.25 API | Admin quản lý chiến dịch khảo sát qua API. |
| Hiển thị danh sách đơn hàng | Bắt buộc | 0.25 | Đã hoàn thành tương đương. Admin xem toàn bộ chiến dịch có phân trang. |
| Cập nhật trạng thái đơn hàng | Bắt buộc | 0.5 | Đã hoàn thành tương đương. Admin duyệt mở hoặc hủy chiến dịch đang chờ; đóng chiến dịch đang mở. Member không được đổi trạng thái. |
| Tìm kiếm đơn hàng | Điểm cộng | 0.25 | Đã hoàn thành tương đương. Admin tìm chiến dịch theo tên hoặc mã, có phân trang. |
| Lọc đơn hàng theo ngày | Điểm cộng | 0.25 | Đã hoàn thành tương đương. Lọc ngày tạo chiến dịch theo giờ Việt Nam; có thể kết hợp từ khóa và phân trang. |

Lưu ý: nhóm trang chủ trong đề ghi tổng 1.75 điểm chức năng, nhưng các dòng bắt buộc cộng được 1.5 điểm. Giữ nguyên số đề và hỏi giảng viên cách tính; không tự cộng hoặc khẳng định điểm được nhận.

Chưa làm: xác thực email (0.5), quên mật khẩu (0.5), Google/Facebook/Zalo (1.5), VNPayment/VietQR (1.0). Tổng tiêu chí điểm cộng chưa làm là 3.5 điểm thô. Ảnh danh mục 0.75 đã được bổ sung.
