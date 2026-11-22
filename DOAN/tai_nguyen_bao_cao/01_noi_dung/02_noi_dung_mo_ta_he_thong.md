# Nội dung mô tả hệ thống

## Bối cảnh và mục tiêu

Doanh nghiệp cần thu thập ý kiến khách hàng, nhân viên hoặc thị trường để đánh giá và cải thiện hoạt động. Việc quản lý nhiều mẫu câu hỏi và phản hồi rời rạc gây khó khăn khi triển khai và tổng hợp. Đề tài xây dựng ứng dụng trên điện thoại giúp quản lý mẫu khảo sát, chuẩn bị kế hoạch, triển khai chiến dịch, thu thập phản hồi và xem kết quả.

Ứng dụng được phát triển bằng Flutter với ngôn ngữ Dart. REST API viết bằng C# ASP.NET Core 10 xử lý nghiệp vụ và lưu dữ liệu tập trung trong SQL Server. SQLite trên điện thoại lưu nháp câu trả lời để người dùng tiếp tục nhập khi mất kết nối.

## Đối tượng và phạm vi

Admin quản trị thành viên và vai trò, danh mục, mẫu khảo sát, ảnh và trạng thái chiến dịch. Member là người dùng trong hệ thống có thể chuẩn bị kế hoạch, tạo chiến dịch, tham gia khảo sát đang mở và xem kết quả chiến dịch mình sở hữu. Admin có thể xem và quản trị các chiến dịch trong hệ thống.

Mô hình hiện tại không tách thêm vai trò doanh nghiệp, nhân viên và khách vãng lai. Người trả lời cần có tài khoản. Đây là ứng dụng dùng nội bộ hoặc trong cùng mạng với máy chủ; chưa có nghiệp vụ bán gói dịch vụ và thanh toán.

## Luồng nghiệp vụ chính

1. Admin tạo danh mục, mẫu khảo sát, ảnh và câu hỏi.
2. Người dùng chọn các mẫu vào kế hoạch và nhập số phản hồi mục tiêu cho từng mẫu.
3. Xác nhận kế hoạch để tạo chiến dịch ở trạng thái chờ duyệt.
4. Admin mở chiến dịch để người dùng tham gia; hoặc hủy khi còn chờ duyệt.
5. Người tham gia trả lời các câu hỏi và gửi phản hồi. Có thể lưu nháp trước khi rời trang.
6. Chủ chiến dịch hoặc Admin xem kết quả; Admin đóng chiến dịch khi kết thúc.

## Xác thực và phân quyền

Đăng ký tạo tài khoản Member. Đăng nhập đúng thông tin được API cấp JWT; mật khẩu được băm bằng BCrypt trong SQL Server. Token được lưu bằng Flutter Secure Storage, không lưu trong bảng nháp SQLite. API kiểm tra trạng thái tài khoản, phiên và vai trò trên mỗi yêu cầu xác thực.

Đổi mật khẩu và đăng xuất trực tuyến làm mất hiệu lực token cũ. Khi Admin sửa thông tin/quyền hoặc khóa tài khoản, tài khoản bị tác động cần đăng nhập lại. Giao diện ẩn chức năng quản trị với Member và server vẫn kiểm tra quyền; ẩn nút không thay cho phân quyền API.

Admin không chỉnh sửa hoặc xóa chính mình tại màn hình quản trị. Thành viên có chiến dịch hoặc phản hồi không được xóa; dùng khóa tài khoản để giữ lịch sử. Vai trò Admin và Member là hai vai trò cố định, chưa có chức năng tạo tên vai trò tùy ý.

## Danh mục và mẫu khảo sát

Danh mục gồm tên, mô tả và ảnh đại diện tùy chọn. Mẫu gồm danh mục, tiêu đề, mô tả, ảnh và danh sách câu hỏi. Thêm mẫu bắt buộc có ảnh; danh mục cũ không có ảnh dùng biểu tượng mặc định. Server nhận PNG/JPEG tối đa 5 MB, kiểm tra chữ ký định dạng và sinh tên file ngẫu nhiên.

Khi thay ảnh thành công, hệ thống xóa ảnh cũ; khi ghi dữ liệu thất bại, ảnh mới được dọn. Khi xóa danh mục hoặc mẫu được phép xóa, file ảnh đi kèm cũng được xóa. Danh mục còn mẫu không được xóa. Mẫu đã có trong bất kỳ chiến dịch nào không được sửa hoặc xóa, kể cả chiến dịch đã đóng/hủy, để giữ nội dung nhất quán với lịch sử.

Trang chủ có mẫu mới nhất, lọc danh mục, tìm theo tên và phân trang 10 mẫu mỗi trang. Chi tiết có mẫu liên quan cùng danh mục, không gồm chính mẫu đang xem và có phân trang.

## Kế hoạch và chiến dịch

Mỗi người dùng có kế hoạch riêng; cùng một mẫu chỉ có một dòng trong kế hoạch. Số phản hồi mục tiêu nằm trong khoảng 1 đến 100000. Badge kế hoạch đếm số mẫu khác nhau, không đếm tổng số phản hồi mục tiêu.

Tạo chiến dịch lưu các dòng kế hoạch thành chi tiết chiến dịch rồi làm trống kế hoạch trong một transaction. RequestId giúp gửi lại cùng yêu cầu không tạo chiến dịch trùng. Chiến dịch có thể tìm theo tên/mã, phân trang và lọc ngày tạo theo giờ Việt Nam. Member chỉ xem danh sách riêng của mình, còn danh sách đang mở dành cho các chiến dịch Active.

Trạng thái hợp lệ: Pending → Active hoặc Cancelled; Active → Closed. Chỉ Admin đổi trạng thái. Chủ chiến dịch và Admin có quyền xem kết quả; người chỉ tham gia không xem kết quả chiến dịch của người khác.

## Câu hỏi và phản hồi

Có bốn loại câu hỏi: văn bản, chọn một, chọn nhiều và đánh giá 1 đến 5. Câu hỏi có thể bắt buộc hoặc không bắt buộc. API kiểm tra câu trả lời theo loại, lựa chọn hợp lệ và số lượng phản hồi mục tiêu.

Mỗi tài khoản trả lời một lần cho mỗi mẫu trong một chiến dịch. SubmissionId giúp thử gửi lại cùng phản hồi mà không tạo bản ghi trùng. Hệ thống không cho gửi khi chiến dịch chưa mở, đã đóng hoặc đã đủ mục tiêu. Kết quả gồm số phản hồi, nội dung trả lời văn bản, số lượt chọn và điểm đánh giá trung bình. Câu chọn nhiều có thể có tổng tỷ lệ lớn hơn 100 phần trăm.

## SQLite và sử dụng không dây

Nháp hiện dùng bảng response_drafts, khóa ghép member_id và item_id. payload_json chứa mẫu, câu trả lời và mã gửi lại; nháp được phân tách theo tài khoản. Bảng survey_drafts là bảng cũ được giữ để tương thích phiên bản database, không phải nơi luồng trả lời hiện tại lưu nháp.

Lưu nháp là thao tác chủ động; các thay đổi chưa bấm Lưu nháp không được đảm bảo giữ lại. Nếu gửi lỗi, nháp đã lưu được giữ. Nháp không tự gửi nền. Đăng xuất xóa nháp của tài khoản trên điện thoại sau bước xác nhận.

App release chạy từ icon mà không cần terminal Flutter. Điện thoại dùng Wi-Fi để truy cập API trên máy tính; địa chỉ có thể thay trong Kết nối máy chủ và được lưu lại. Máy tính vẫn phải bật API và SQL Server. Không có mạng thì chỉ làm việc với các nháp đã lưu; chưa hỗ trợ toàn bộ hệ thống offline. Địa chỉ nội bộ không dùng được từ mọi mạng Internet.

## Kết quả và hướng phát triển

Đã triển khai nhóm chức năng bắt buộc theo nghiệp vụ khảo sát, cùng ảnh danh mục, mẫu liên quan có phân trang, tìm kiếm/lọc ngày chiến dịch và các ràng buộc bảo toàn dữ liệu. Kết quả kiểm thử tự động gần nhất gồm 134 lượt API và 10 kiểm thử Flutter; bản release build và cài cập nhật thành công. Người dùng đã xác nhận dùng qua Wi-Fi ổn.

Chưa triển khai xác thực email, quên mật khẩu và đăng nhập Google/Facebook/Zalo. Các phần này cần cấu hình dịch vụ bên ngoài và kiểm thử bổ sung. Thanh toán chưa phù hợp vì hiện không thu tiền. Nếu triển khai ra Internet, cần máy chủ HTTPS, cấu hình vận hành và khóa ký phát hành riêng.
