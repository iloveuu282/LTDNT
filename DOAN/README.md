# Ứng dụng hỗ trợ khảo sát cho doanh nghiệp

Công nghệ bắt buộc: Flutter/Dart, SQLite trên điện thoại, REST API ASP.NET Core 10 và SQL Server.

## Cách thực hiện

Theo yêu cầu mới, hoàn thiện toàn bộ chức năng bắt buộc và tự kiểm tra từng nhóm trước khi bàn giao một bản để người dùng test toàn bộ. Chỉ làm điểm cộng sau khi bản bắt buộc ổn định. Nếu phát hiện vấn đề ảnh hưởng phần trước, cập nhật tài liệu và mã nguồn liên quan.

## Trạng thái

Toàn bộ mã nguồn ứng dụng sẽ đặt trong `cuoiki/` (Flutter tại `cuoiki/survey_app/`, API tại `cuoiki/SurveyApi/`). Tài liệu đặt trong `docs/`.

Kế hoạch có lộ trình lưu tài liệu và minh chứng để viết báo cáo Word về sau; hiện chưa tạo báo cáo Word.

- Đã lập và đơn giản hóa kế hoạch theo yêu cầu người dùng.
- Đã bắt đầu code: khởi tạo Flutter/API, database và đăng ký/đăng nhập/logout cục bộ. Xem [kết quả kiểm tra](docs/first-build-check.md) và [hướng dẫn chạy](cuoiki/README.md).
- Đã code các nhóm chức năng bắt buộc theo phương án khảo sát; xem [kết quả kiểm tra bản đầy đủ](docs/mandatory-build-check.md) và [checklist test toàn bộ](docs/full-test-checklist.md). Chưa coi là nghiệm thu trên điện thoại.
- Đã bổ sung đổi mật khẩu, quản lý member và phân quyền Admin/Member; xem [kiểm tra phần tài khoản](docs/member-management-check.md). Chờ kiểm tra màn hình mới trên điện thoại.

Đây là phạm vi dự kiến, chưa phải xác nhận của giảng viên về điểm chức năng tương đương.
