# Giới hạn và điều dễ nói nhầm

| Nói dễ sai | Cách nói đúng với bản hiện tại |
| --- | --- |
| Flutter nên app đã chạy mọi nền tảng | Công nghệ đa nền tảng, triển khai/kiểm chứng hiện tại trên Android |
| Rút USB là app không cần máy chủ | Release không cần Flutter debugger; online vẫn cần API và SQL Server |
| SQLite đồng bộ mọi dữ liệu | Chỉ lưu nháp theo tài khoản/ItemId; không full cache hoặc sync nền |
| Token nằm trong SQLite | Token/member/server_url dùng Flutter Secure Storage |
| JWT mã hóa toàn bộ dữ liệu | JWT có chữ ký và thời hạn, payload không tự được mã hóa |
| Mật khẩu mã hóa rồi giải mã khi login | BCrypt hash và Verify, không giải mã |
| Role có thêm/xóa tùy ý | Chỉ gán Admin hoặc Member cố định |
| Member có canManage thì đổi status được | canManage dùng hiển thị kết quả; Status endpoint chỉ Admin |
| Mẫu hết chiến dịch thì sửa lại được | Đã có CampaignItems thì vẫn khóa sửa/xóa kể cả Closed/Cancelled |
| Một người chỉ trả lời một mẫu một lần trong toàn app | Một lần trên ItemId; có thể trả lời cùng mẫu ở chiến dịch khác |
| Nhập dở tự lưu mọi lúc | Lưu khi bấm Lưu nháp hoặc trước khi gửi; chưa có autosave theo từng ký tự |
| Logout chỉ xóa token, giữ mọi nháp | HomePage xóa nháp tài khoản sau xác nhận; đổi mật khẩu thành công cũng dọn nháp |
| Logout offline thu hồi mọi token server | Chỉ dọn local nếu chưa liên hệ được API, có thông báo giới hạn |
| File ảnh và SQL commit chung một transaction | Code phối hợp lưu/dọn file với transaction SQL, không distributed transaction |
| Kiểm tra chữ ký ảnh là quét bảo mật đầy đủ | Chỉ kiểm tra header định dạng và kích thước cơ bản |
| JWT bảo vệ cả URL ảnh | Static files được phục vụ trực tiếp; ảnh không có cơ chế quyền riêng |
| Kết quả tính hết ở Flutter | API tổng hợp text/lượt chọn/trung bình; Flutter hiển thị và tính tỷ lệ |
| 134 API + 10 Flutter + 6 Android là một bộ test 150 ca | Ba loại bằng chứng khác nhau, không gộp tùy tiện |
| Đã làm bảng tương đương là chắc chắn có điểm | Cần giảng viên công nhận quy đổi và cách tính |

Chưa triển khai email xác thực, quên mật khẩu, Google/Facebook/Zalo, thu tiền, xuất Excel/PDF, full offline, refresh token, phân vai doanh nghiệp/khách vãng lai và vận hành Internet hoàn chỉnh. Các nội dung này là giới hạn/hướng phát triển, không phải lỗi cần che đi khi giải trình.

Hệ thống không có chức năng sửa/xóa phản hồi đã gửi hoặc xóa chiến dịch trong app hiện tại. Không tự hứa có các chức năng đó chỉ vì đã có CRUD mẫu khảo sát.
