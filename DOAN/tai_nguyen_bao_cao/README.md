# Tài nguyên làm báo cáo Word

Đề tài: Xây dựng ứng dụng hỗ trợ khảo sát cho doanh nghiệp.
Cập nhật ngày 19/11/2026, sau khi bổ sung ảnh danh mục và người dùng xác nhận dùng qua Wi-Fi ổn.

## Đọc và sử dụng theo thứ tự

| Thư mục | Nội dung | Dùng trong Word |
| --- | --- | --- |
| 01_noi_dung | Đề cương, nội dung mô tả, giải trình và câu hỏi thường gặp | Viết các chương và phần kết luận |
| 02_doi_chieu | Bảng yêu cầu cập nhật dạng Markdown và CSV, ma trận quyền | Chèn bảng đối chiếu và bảng phân quyền |
| 03_so_do | Ảnh PNG độ phân giải cao và mã nguồn Mermaid | Insert → Pictures để chèn PNG; có thể sửa sơ đồ từ file nguồn |
| 04_co_so_du_lieu | Script tạo/cập nhật SQL Server, schema SQLite và từ điển dữ liệu | Chương thiết kế và phụ lục |
| 05_kiem_thu | Log API, minh chứng SQLite Android, mô tả kết quả và mẫu bảng kiểm thử thực tế | Chương kiểm thử |
| 06_anh_minh_chung | Các thư mục ảnh theo chức năng, danh sách ảnh và chú thích dự kiến | Chèn ảnh thao tác thực tế trên app |
| 07_huong_dan | Hướng dẫn chạy, danh sách API, cấu trúc mã nguồn và danh sách hồ sơ nộp | Phần triển khai và phụ lục |

Ảnh sơ đồ đã được xuất PNG để chèn trực tiếp vào Word. CSV dùng UTF-8 có BOM để mở bằng Excel; chọn bảng rồi sao chép vào Word hoặc dùng bản Markdown làm nguồn nội dung.

Các thư mục ảnh chức năng được tạo sẵn nhưng chưa đủ ảnh. Đọc 06_anh_minh_chung/danh_sach_anh_can_chup.md rồi chụp trên bản app cuối. Ảnh thử nghiệm cũ nằm riêng trong kiem_thu_ky_thuat và tham_khao_cu; không dùng ảnh đang tải làm bằng chứng chức năng đã thành công.

Trước khi nộp: điền tên trường, môn học, sinh viên, MSSV, lớp và giảng viên trong đề cương; thay ảnh minh chứng; hoàn thành bảng kiểm thử thực tế. Thư mục này là tài nguyên để soạn báo cáo, chưa phải báo cáo Word cuối cùng.

Không có mật khẩu, token JWT, khóa ký, khóa .local-jwt-key, database chứa tài khoản thật hoặc cấu hình bí mật trong bộ tài nguyên. Ảnh chụp cần che thông tin cá nhân không cần thiết. Các script database là schema, không phải bản sao lưu dữ liệu thực tế.

Bảng đối chiếu ở 02_doi_chieu là bản cập nhật; file Word đối chiếu trước đây trong DOAN/docs được tạo trước lúc bổ sung ảnh danh mục nên không sao chép vào đây để tránh dùng nhầm trạng thái cũ.
