# Đổi mật khẩu, quản lý thành viên và vai trò

Ngày thực hiện: 19/11/2026. Bản đầu đã được người dùng xác nhận chạy ổn trên điện thoại trước khi thực hiện phần này.

## Thay đổi

- Migration 002 thêm IsActive và TokenVersion vào Members, giữ nguyên dữ liệu hiện có.
- API kiểm tra tài khoản còn hoạt động, phiên còn hiệu lực và vai trò khớp database trên mỗi yêu cầu có JWT.
- Đổi mật khẩu kiểm tra mật khẩu hiện tại, không chấp nhận giữ nguyên mật khẩu; băm BCrypt và thu hồi các phiên cũ.
- Logout thu hồi các phiên của tài khoản ở máy chủ trước khi xóa token cục bộ.
- Admin xem danh sách thành viên/role, sửa tên, khóa/mở, gán role, xóa Member chưa có ràng buộc dữ liệu. Không trả password hash ra API danh sách.
- Hai role cố định Admin và Member. Không có tạo role tùy ý hoặc quản lý nhiều doanh nghiệp.
- Không chỉnh sửa/xóa chính mình trong phần quản trị. Muốn xóa Admin khác phải chuyển về Member trước.
- Flutter thêm ChangePasswordPage, MemberPage và menu theo role; giữ Model/Repository/Page, không thêm kiến trúc nhiều tầng.
- File 003 hướng dẫn cấp quyền Admin đầu tiên cho email do người dùng chọn; chưa tự cấp quyền cho tài khoản thật.

## Kiểm tra API thực tế

Chạy API mới tại localhost:5081 để không thay tiến trình đang dùng trên 5080. Tạo hai tài khoản tạm, cấp Admin cho đúng tài khoản kiểm thử bằng SQL, kiểm tra rồi xóa cả hai tài khoản tạm.

| Tình huống | Kết quả |
| --- | --- |
| Đăng ký gửi thêm role Admin | Tài khoản vẫn là Member |
| Chưa đăng nhập gọi danh sách thành viên | 401 |
| Member gọi API Admin | 403 |
| Admin xem danh sách thành viên và role | 200, đúng cấu trúc, không lộ password hash |
| Admin tự đổi quyền/khóa chính mình hoặc tự xóa | 400 |
| Đổi mật khẩu với mật khẩu hiện tại sai | 400 |
| Đổi mật khẩu đúng | 200 |
| Dùng token cũ sau đổi mật khẩu | 401 |
| Đăng nhập bằng mật khẩu cũ | 401 |
| Đăng nhập bằng mật khẩu mới | Thành công |
| Gán Member thành Admin | 200, token cũ bị từ chối |
| Admin được gán quyền đăng nhập lại và gọi quản trị | 200 |
| Khóa và hạ quyền Admin khác | 200, token trước đó bị từ chối |
| Tài khoản khóa đăng nhập | 401 |
| Mở khóa | 200, đăng nhập lại được |
| Logout và dùng lại token | Logout 200, token bị từ chối 401 |
| Xóa Member rồi đăng nhập | Xóa 200, đăng nhập 401 |

Flutter analyze: không có lỗi/cảnh báo. Ba widget test đạt: chuyển sang đăng ký, menu theo Admin/Member, chặn xác nhận mật khẩu không khớp. APK debug build thành công. Chưa xác nhận thao tác màn hình mới trên điện thoại thật.

## Kịch bản người dùng kiểm tra

1. Khởi động lại API và Flutter theo cách cũ: dotnet run và flutter run.
2. Member: thử sai mật khẩu hiện tại, xác nhận không khớp, đổi thành công; đăng nhập lại bằng mật khẩu mới.
3. Cấp Admin đầu tiên cho email đã chọn theo README; đăng nhập lại.
4. Admin mở Thành viên và vai trò; sửa tên của tài khoản thử khác, khóa và thử đăng nhập, mở khóa, đổi role và đăng nhập lại để thấy quyền mới.
5. Xóa một Member chỉ dùng để thử. Không dùng tài khoản đang có dữ liệu cần giữ.

Chưa làm danh mục và mẫu khảo sát ở bước này.
