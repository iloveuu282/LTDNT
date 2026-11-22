# Ma trận phân quyền

| Chức năng | Chưa đăng nhập | Member | Admin |
| --- | --- | --- | --- |
| Đăng ký và đăng nhập | Có | Đăng xuất trước để đổi tài khoản | Đăng xuất trước để đổi tài khoản |
| Cấu hình kết nối máy chủ | Có | Có | Có |
| Xem danh mục, mẫu, tìm kiếm, chi tiết | Không | Có | Có |
| Thêm/sửa/xóa danh mục, ảnh | Không | Không | Có, theo ràng buộc dữ liệu |
| Thêm/sửa/xóa mẫu và câu hỏi | Không | Không | Có; mẫu đã dùng bị khóa sửa/xóa |
| Quản lý thành viên và gán Admin/Member | Không | Không | Có; không tự sửa/xóa mình |
| Kế hoạch và tạo chiến dịch | Không | Kế hoạch riêng | Kế hoạch riêng |
| Danh sách chiến dịch | Không | Của mình | Toàn bộ |
| Danh sách chiến dịch đang mở và tham gia | Không | Có | Có |
| Đổi trạng thái chiến dịch | Không | Không | Có, đúng luồng trạng thái |
| Xem kết quả | Không | Chiến dịch mình sở hữu | Có |
| Đổi mật khẩu, đăng xuất | Không | Tài khoản của mình | Tài khoản của mình |
| Nháp SQLite | Không đăng nhập mới được khi offline | Nháp của tài khoản đã lưu phiên | Nháp của tài khoản đã lưu phiên |

Quyền API được kiểm tra phía server. Hồ sơ lưu trên điện thoại chỉ giúp mở lại app và nháp; không cấp quyền truy cập server khi token hết hạn hoặc tài khoản đã bị khóa.
