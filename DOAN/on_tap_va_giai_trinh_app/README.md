# Ôn tập và giải trình toàn bộ ứng dụng

Đề tài: Xây dựng ứng dụng hỗ trợ khảo sát cho doanh nghiệp.
Đây là tài liệu ôn theo mã nguồn hiện tại ngày 19/11/2026, không phải một báo cáo Word mới. Tài liệu giải thích việc app làm được, đường đi của dữ liệu và vị trí mở code để trả lời giảng viên.

## Thứ tự đọc

| Tài liệu | Dùng để làm gì |
| --- | --- |
| [01 Tổng quan](01_tong_quan_va_thuat_ngu.md) | Nắm bài toán, công nghệ và từ vựng |
| [02 Bản đồ màn hình](02_ban_do_man_hinh.md) | Màn hình nào ở file nào; vào bằng nút nào |
| [03 Flutter](03_hieu_ma_flutter.md) | Hiểu từng lớp, trạng thái giao diện và repository |
| [04 API](04_hieu_api_csharp.md) | Controller, model, repository, endpoint và mã HTTP |
| [05 Luồng xuyên suốt](05_luong_xu_ly_tung_chuc_nang.md) | Theo một lần bấm từ màn hình tới SQL/SQLite |
| [06 Database](06_co_so_du_lieu_va_json.md) | Bảng, khóa, quan hệ và các mẫu JSON |
| [07 Code cần hiểu](07_doan_code_can_giai_thich.md) | Đoạn code thật kèm cách đọc và câu hỏi |
| [08 Quyền và dữ liệu](08_phan_quyen_bao_toan_du_lieu.md) | Ràng buộc, giao dịch và chống gửi trùng |
| [09 Đối chiếu đề](09_giai_trinh_yeu_cau_va_nghiep_vu.md) | Trực tiếp, tương đương và phần riêng của đề tài |
| [10 Hỏi đáp](10_cau_hoi_giang_vien_va_cach_tra_loi.md) | Các câu hỏi có khả năng được hỏi |
| [11 Lộ trình ôn](11_lo_trinh_on_va_tu_kiem_tra.md) | Ôn theo từng vòng và tự kiểm tra mức hiểu |
| [12 Chạy và tìm lỗi](12_chay_he_thong_va_tim_loi.md) | Chạy USB/Wi-Fi, offline và kiểm thử |
| [13 Mục lục code](13_muc_luc_file_va_ham.md) | Danh mục file, lớp và hàm kèm số dòng |
| [14 Điều cần nói đúng](14_gioi_han_va_diem_de_nham.md) | Tránh trình bày vượt quá chức năng đã làm |
| [15 Tờ ôn nhanh](15_to_on_nhanh.md) | Các ý cần nhớ trước khi giải trình |
| [16 Cú pháp cần hiểu](16_tu_dien_cu_phap_dart_csharp.md) | Đọc các ký hiệu Dart và C# xuất hiện trong dự án |
| [17 Minh họa dữ liệu](17_minh_hoa_du_lieu_cho_giang_vien.md) | Tạo tài khoản thì lưu đâu; cách chỉ dữ liệu thật trong SSMS |
| phu_luc | Sơ đồ PNG, bảng đối chiếu và ma trận quyền |

Mỗi đường dẫn mở file code thật trong DOAN/cuoiki. Số dòng là mốc của bản hiện tại: mở file, dùng Ctrl+G để tới dòng hoặc Ctrl+F tìm tên hàm. Nếu code thay đổi thì dùng tên hàm làm mốc; mau_nguon_da_doi_chieu.json lưu thông tin phiên bản được đối chiếu.

Không cần học thuộc từng dòng hoặc đọc tất cả một lần. Mục tiêu là giải thích được mục đích, đường đi dữ liệu, cách kiểm tra và giới hạn của từng chức năng. Các ví dụ JSON/SQL dùng dữ liệu giả, không phải dữ liệu hoặc mật khẩu thật.
