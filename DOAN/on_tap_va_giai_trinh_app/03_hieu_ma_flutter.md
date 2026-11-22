# Hiểu cấu trúc và mã Flutter

## Cách tách thư mục

`models` mô tả dữ liệu, `pages` dựng giao diện và xử lý thao tác, `repositories` chuyển thao tác thành HTTP request, `services` lo kết nối/phiên chung, `local` thao tác SQLite và `widgets` chứa thành phần dùng lại. Cách tổ chức học từ trek_bikes_app; không gọi đây là một triển khai Clean Architecture đầy đủ hoặc một dự án dùng Bloc/Provider vì app không dùng các thư viện quản lý trạng thái đó.

## Luồng khởi động

[main.dart](<../cuoiki/survey_app/lib/main.dart>) — dòng 10: ensureInitialized → LocalDatabase.open → ApiService.initialize → runApp. SurveyApp dựng MaterialApp và SafeArea. _SessionPage đọc SessionHelper.restore bằng FutureBuilder. Đọc xong hồ sơ thì vào HomePage hoặc LoginPage.

SessionHelper.restore kiểm tra token/hồ sơ cục bộ, không gọi auth/me để xác minh phiên ngay tại bước này. Vì vậy offline vẫn vào nháp được; API sẽ từ chối token không hợp lệ ở những chức năng online.

## State và vòng đời

- StatefulWidget giữ cấu hình bất biến như surveyId, memberId và admin; lớp State giữ danh sách, controller, cờ busy và lỗi.
- initState chạy khi State được tạo; thường gọi _load để lấy dữ liệu.
- setState báo Flutter dựng lại giao diện theo giá trị mới. Nó không tự ghi database.
- async/await chờ kết quả không khóa luồng giao diện theo cách chờ đồng bộ.
- mounted kiểm tra State còn gắn với cây widget sau await; tránh setState hoặc điều hướng trên màn hình đã bị đóng.
- dispose giải phóng TextEditingController. Không phải nơi tự xóa nháp hoặc dữ liệu server.
- _busy/_loading/_saving quyết định spinner và khóa nút; try/catch/finally cập nhật lỗi và bỏ trạng thái đang xử lý.
- GlobalKey<FormState> truy cập validate của biểu mẫu; TextEditingController đọc dữ liệu đang nhập.

## Điều hướng

Navigator.push mở trang mới; Navigator.pop đóng và có thể trả kết quả; pushReplacement thay trang hiện tại; pushAndRemoveUntil xóa các route trước khi về LoginPage sau logout/đổi mật khẩu. MaterialPageRoute và DialogRoute là cách dựng route, không phải URL REST.

HomePage._open quay lại sẽ tăng _revision để tái tạo SurveyListView rồi cập nhật badge. SurveyListView._details tải lại sau khi quay về từ chi tiết. Đọc tại [home_page.dart](<../cuoiki/survey_app/lib/pages/home_page.dart>) — dòng 44 và [survey_list_view.dart](<../cuoiki/survey_app/lib/pages/survey_list_view.dart>) — dòng 78.

## Model và JSON

- [member.dart](<../cuoiki/survey_app/lib/models/member.dart>) — dòng 1: hồ sơ tài khoản, role và trạng thái hiển thị.
- [survey.dart](<../cuoiki/survey_app/lib/models/survey.dart>) — dòng 1: Category và imagePath nullable; danh mục cũ có thể không có ảnh.
- Cùng file chứa Question, Survey, PlanItem, Campaign, CampaignItem và PageData. fromMap nhận dữ liệu camelCase từ JSON. Survey.toMap và Question.toMap phục vụ nháp/upload câu hỏi.
- jsonEncode chuyển object/map thành chuỗi JSON; jsonDecode làm ngược lại. Không dùng chung khái niệm với encryption hoặc hash.

## Ba repository Dart

| File | Nhóm hàm |
| --- | --- |
| [member_repository.dart](<../cuoiki/survey_app/lib/repositories/member_repository.dart>) — dòng 9 | đăng ký, đăng nhập, đổi mật khẩu, logout, thành viên và role |
| [survey_repository.dart](<../cuoiki/survey_app/lib/repositories/survey_repository.dart>) — dòng 10 | danh mục, ảnh danh mục, mẫu, chi tiết và mẫu liên quan |
| [campaign_repository.dart](<../cuoiki/survey_app/lib/repositories/campaign_repository.dart>) — dòng 6 | kế hoạch, tạo chiến dịch, danh sách, trạng thái, gửi phản hồi và kết quả |

MemberRepository._post là đường HTTP riêng cho đăng ký/đăng nhập không cần token. Các lời gọi nghiệp vụ còn lại dùng ApiService.request; upload dùng MultipartRequest và ApiService.upload. Các repository đều lấy baseUrl hiện tại từ ApiService, nên đổi Wi-Fi không cần sửa mỗi file.

## ApiService và SessionHelper

[api_service.dart](<../cuoiki/survey_app/lib/services/api_service.dart>) — dòng 9: normalizeUrl kiểm tra URL gốc HTTP/HTTPS; initialize đọc URL lưu; checkServer gọi health không gửi JWT; saveServer ghi URL; request thêm Bearer token; upload gửi multipart; decode chuyển HTTP lỗi thành exception; imageUrl ghép đường dẫn ảnh với máy chủ.

Không diễn giải timeout là một giá trị duy nhất cho toàn bộ app: kiểm tra health 8 giây; auth _post 15 giây; request và stream phản hồi có timeout từng bước 20 giây; upload từng bước 30 giây. Các giá trị là giới hạn chờ từng lời gọi/bước, không đảm bảo tổng thời gian chỉ bằng một số đó.

[session_helper.dart](<../cuoiki/survey_app/lib/services/session_helper.dart>) — dòng 7: save lưu member/token; restore đọc hồ sơ; token lấy token; clear chỉ xóa token/member. server_url không bị xóa bởi logout. Nháp được dọn riêng ở các trang khi logout/đổi mật khẩu, không nằm trong SessionHelper.clear.

## Widget dùng lại

- [common.dart](<../cuoiki/survey_app/lib/widgets/common.dart>) — dòng 32: nút trước/sau và tổng kết quả, mặc định giao diện dùng 10 mục/trang.
- Cùng file có errorText, showMessage và confirmAction.
- [category_image.dart](<../cuoiki/survey_app/lib/widgets/category_image.dart>) — dòng 5: ảnh danh mục hoặc icon thư mục khi thiếu/lỗi ảnh.
- ListView/SingleChildScrollView giúp cuộn khi bàn phím chiếm chiều cao; không tắt resizeToAvoidBottomInset để che lỗi layout.

## SQLite

[local_database.dart](<../cuoiki/survey_app/lib/local/local_database.dart>) — dòng 4: open tạo database phiên bản 2; onUpgrade thêm response_drafts cho bản cũ. saveDraft dùng ConflictAlgorithm.replace trên khóa ghép để cập nhật nháp hiện có. draft/drafts đọc riêng theo member; deleteDraft xóa một nháp; clearDrafts xóa của một tài khoản. API không đọc database SQLite từ điện thoại.
