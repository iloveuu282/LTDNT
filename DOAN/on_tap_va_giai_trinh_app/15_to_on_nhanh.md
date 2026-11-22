# Tờ ôn nhanh

## Giới thiệu

Ứng dụng Flutter Dart hỗ trợ doanh nghiệp quản lý mẫu, triển khai chiến dịch, thu phản hồi và xem kết quả. API C# ASP.NET Core 10 cùng SQL Server lưu tập trung; SQLite lưu nháp trên Android.

## Tìm code ngay

- Khởi động: lib/main.dart; API: SurveyApi/Program.cs.
- Đăng nhập/đăng ký: pages/login_page.dart.
- Trang chủ/menu: home_page.dart; danh sách thật: survey_list_view.dart.
- Thành viên/role: member_page.dart; danh mục/ảnh: category_page.dart.
- Mẫu và QuestionDialog: survey_edit_page.dart; chi tiết/liên quan: survey_details_page.dart.
- Kế hoạch và _TargetDialog: plan_page.dart.
- Chiến dịch: campaign_list_page.dart và campaign_details_page.dart.
- Trả lời: response_page.dart; nháp: drafts_page.dart; kết quả: results_page.dart.
- URL/token: services/api_service.dart và session_helper.dart.
- SQLite: local/local_database.dart.
- Quy tắc câu hỏi/đáp án: API Api/Models/SurveyRules.cs.
- Giao dịch tạo/gửi: API Api/Models/CampaignRepository.cs.
- Upload file: API Services/ImageService.cs.

## Đường đi cần nhớ

Page Dart → Repository Dart → HTTP → Controller C# → Repository C#/Service → SQL Server hoặc file ảnh → JSON → model → setState hiển thị.

Nháp: ResponsePage → LocalDatabase → SQLite. Trước khi gửi lưu payload, sau khi gửi thành công xóa nháp. Mất mạng giữ nháp và mã gửi để thử lại.

## Năm ràng buộc

1. Role/quyền sở hữu kiểm tra ở API, không chỉ ẩn nút.
2. Danh mục có mẫu không được xóa; mẫu có CampaignItems không sửa/xóa.
3. RequestId chống tạo chiến dịch trùng; SubmissionId chống gửi cùng phản hồi trùng.
4. Chỉ Active, chưa trả lời và chưa đủ mục tiêu mới nhận phản hồi mới.
5. Chủ chiến dịch/Admin xem kết quả; chỉ Admin đổi trạng thái.

## Giải trình tương đương

Sản phẩm → mẫu; giỏ hàng → kế hoạch; số lượng → chỉ tiêu; checkout → tạo chiến dịch; đơn hàng → chiến dịch. Phần riêng đề tài: câu hỏi, trả lời, thống kê, quyền xem kết quả và nháp offline. Không có nghiệp vụ thu tiền.

## Các con số

JWT 8 giờ; clock skew 30 giây. Mục tiêu 1–100000. Mẫu 1–50 câu. Lựa chọn 2–20 mục. Rating 1–5. Ảnh PNG/JPEG tối đa 5 MiB. App 10 mục/trang. API 134 lượt kiểm tra và Flutter 10 test đã đạt; 6 kiểm tra SQLite thiết bị là đợt riêng trước đó.

Đừng chỉ học các con số: phải mở được hàm kiểm tra và giải thích lý do/ràng buộc. Số dòng và lớp nằm trong 13_muc_luc_file_va_ham.md.
