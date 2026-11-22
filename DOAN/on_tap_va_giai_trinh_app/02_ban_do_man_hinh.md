# Bản đồ màn hình và file code

Số dòng đi cùng tên lớp để tra nhanh; các hàm trùng _load/_save cần tìm trong đúng lớp State. Đăng ký, dialog và widget nhúng được ghi riêng để tránh nhầm thành file không tồn tại.

| Màn hình hoặc thành phần | File và lớp | Cách mở |
| --- | --- | --- |
| Khởi động và khôi phục phiên | [main.dart](<../cuoiki/survey_app/lib/main.dart>) — dòng 26; `SurveyApp` | Mở app từ icon |
| Đăng nhập và đăng ký | [login_page.dart](<../cuoiki/survey_app/lib/pages/login_page.dart>) — dòng 9; `LoginPage` | Mở app chưa có phiên; bấm Chưa có tài khoản? Đăng ký |
| Trang chủ | [home_page.dart](<../cuoiki/survey_app/lib/pages/home_page.dart>) — dòng 17; `HomePage` | Đăng nhập thành công hoặc khôi phục hồ sơ |
| Danh sách mẫu tại trang chủ | [survey_list_view.dart](<../cuoiki/survey_app/lib/pages/survey_list_view.dart>) — dòng 11; `SurveyListView` | Được HomePage nhúng vào body |
| Đổi mật khẩu | [change_password_page.dart](<../cuoiki/survey_app/lib/pages/change_password_page.dart>) — dòng 8; `ChangePasswordPage` | Trang chủ → Đổi mật khẩu |
| Thành viên và vai trò | [member_page.dart](<../cuoiki/survey_app/lib/pages/member_page.dart>) — dòng 6; `MemberPage` | Menu Admin → Thành viên và vai trò |
| Danh mục và ảnh | [category_page.dart](<../cuoiki/survey_app/lib/pages/category_page.dart>) — dòng 12; `CategoryPage` | Menu Admin → Danh mục |
| Thêm hoặc sửa mẫu | [survey_edit_page.dart](<../cuoiki/survey_app/lib/pages/survey_edit_page.dart>) — dòng 8; `SurveyEditPage` | Admin → Thêm mẫu; hoặc Chi tiết mẫu → Sửa mẫu |
| Hộp thoại câu hỏi | [survey_edit_page.dart](<../cuoiki/survey_app/lib/pages/survey_edit_page.dart>) — dòng 241; `QuestionDialog` | Trong trang thêm/sửa mẫu → Thêm câu hỏi hoặc icon sửa câu hỏi |
| Chi tiết mẫu và mẫu liên quan | [survey_details_page.dart](<../cuoiki/survey_app/lib/pages/survey_details_page.dart>) — dòng 10; `SurveyDetailsPage` | Bấm một mẫu ở danh sách hoặc mẫu liên quan |
| Kế hoạch triển khai | [plan_page.dart](<../cuoiki/survey_app/lib/pages/plan_page.dart>) — dòng 8; `PlanPage` | Icon bảng kế hoạch tại AppBar trang chủ |
| Danh sách chiến dịch | [campaign_list_page.dart](<../cuoiki/survey_app/lib/pages/campaign_list_page.dart>) — dòng 8; `CampaignListPage` | Trang chủ → Chiến dịch của tôi/Quản lý chiến dịch/Khảo sát đang mở |
| Chi tiết chiến dịch | [campaign_details_page.dart](<../cuoiki/survey_app/lib/pages/campaign_details_page.dart>) — dòng 9; `CampaignDetailsPage` | Bấm chiến dịch; hoặc vừa tạo chiến dịch từ kế hoạch |
| Trả lời khảo sát | [response_page.dart](<../cuoiki/survey_app/lib/pages/response_page.dart>) — dòng 11; `ResponsePage` | Chiến dịch Active → Trả lời khảo sát; hoặc mở một nháp |
| Danh sách bản nháp | [drafts_page.dart](<../cuoiki/survey_app/lib/pages/drafts_page.dart>) — dòng 9; `DraftsPage` | Trang chủ → Bản nháp |
| Kết quả khảo sát | [results_page.dart](<../cuoiki/survey_app/lib/pages/results_page.dart>) — dòng 6; `ResultsPage` | Chi tiết chiến dịch → Xem kết quả |
| Kết nối máy chủ | [server_settings_page.dart](<../cuoiki/survey_app/lib/pages/server_settings_page.dart>) — dòng 6; `ServerSettingsPage` | Icon bánh răng tại LoginPage hoặc HomePage |

## Khởi động và khôi phục phiên
- Vị trí: [main.dart](<../cuoiki/survey_app/lib/main.dart>) — dòng 26.
- Lớp: `SurveyApp`. Hàm cần đọc: `main, _SessionPageState.build`.
- Đường đi: Mở app từ icon.
- Gọi tiếp: SessionHelper.restore; chưa gọi API để xác thực lại ngay khi mở.
- Dữ liệu liên quan: SQLite mở database; Secure Storage đọc hồ sơ/token.

WidgetsFlutterBinding khởi tạo plugin, mở database và đọc URL, sau đó runApp. FutureBuilder quyết định vào LoginPage hay HomePage. Hồ sơ cục bộ không thay thế kiểm tra quyền phía server.

## Đăng nhập và đăng ký
- Vị trí: [login_page.dart](<../cuoiki/survey_app/lib/pages/login_page.dart>) — dòng 9.
- Lớp: `LoginPage`. Hàm cần đọc: `_submit`.
- Đường đi: Mở app chưa có phiên; bấm Chưa có tài khoản? Đăng ký.
- Gọi tiếp: MemberRepository.login/register → AuthController.Login/Register.
- Dữ liệu liên quan: Members và Roles; token/hồ sơ vào Secure Storage.

Chỉ một file cho cả hai chế độ. Biến _register đổi giao diện. Đăng ký xong quay về chế độ đăng nhập, không tự tạo Admin.

## Trang chủ
- Vị trí: [home_page.dart](<../cuoiki/survey_app/lib/pages/home_page.dart>) — dòng 17.
- Lớp: `HomePage`. Hàm cần đọc: `_open, _refreshPlan, _logout`.
- Đường đi: Đăng nhập thành công hoặc khôi phục hồ sơ.
- Gọi tiếp: CampaignRepository.plan; MemberRepository.logout.
- Dữ liệu liên quan: PlanItems; Secure Storage và nháp khi logout.

Là khung trang chủ: hồ sơ, menu chức năng, icon kế hoạch/badge, kết nối và logout. Phần danh sách thực tế nằm trong SurveyListView.

## Danh sách mẫu tại trang chủ
- Vị trí: [survey_list_view.dart](<../cuoiki/survey_app/lib/pages/survey_list_view.dart>) — dòng 11.
- Lớp: `SurveyListView`. Hàm cần đọc: `_load, _details, _add`.
- Đường đi: Được HomePage nhúng vào body.
- Gọi tiếp: SurveyRepository.categories/getPage → CategoryController.Get, SurveyController.Get.
- Dữ liệu liên quan: Categories và Surveys.

Đây là widget nội dung dùng trong trang chủ, không phải một route trang riêng. Tìm kiếm, lọc danh mục, phân trang và ảnh đều ở đây. _request tránh phản hồi cũ ghi đè lần tải mới.

## Đổi mật khẩu
- Vị trí: [change_password_page.dart](<../cuoiki/survey_app/lib/pages/change_password_page.dart>) — dòng 8.
- Lớp: `ChangePasswordPage`. Hàm cần đọc: `_save`.
- Đường đi: Trang chủ → Đổi mật khẩu.
- Gọi tiếp: MemberRepository.changePassword → AuthController.ChangePassword.
- Dữ liệu liên quan: Members.PasswordHash và TokenVersion; xóa phiên/nháp cục bộ.

Kiểm tra mật khẩu xác nhận tại Flutter; API kiểm tra mật khẩu hiện tại. Thành công yêu cầu đăng nhập lại và app xóa nháp của tài khoản.

## Thành viên và vai trò
- Vị trí: [member_page.dart](<../cuoiki/survey_app/lib/pages/member_page.dart>) — dòng 6.
- Lớp: `MemberPage`. Hàm cần đọc: `_load, _edit, _delete`.
- Đường đi: Menu Admin → Thành viên và vai trò.
- Gọi tiếp: MemberRepository.getMembers/getRoles/updateMember/deleteMember → MemberController.
- Dữ liệu liên quan: Members và Roles.

Dialog sửa viết ngay trong _edit bằng DialogRoute và StatefulBuilder; không có trang role riêng. Không cho sửa/xóa chính mình.

## Danh mục và ảnh
- Vị trí: [category_page.dart](<../cuoiki/survey_app/lib/pages/category_page.dart>) — dòng 12.
- Lớp: `CategoryPage`. Hàm cần đọc: `_load, _edit, _delete; _CategoryDialogState._pickImage/_save`.
- Đường đi: Menu Admin → Danh mục.
- Gọi tiếp: SurveyRepository.categories/saveCategory/deleteCategory → CategoryController.
- Dữ liệu liên quan: Categories và wwwroot/uploads.

Danh sách và dialog thêm/sửa chung file. Bỏ ảnh chỉ thay trạng thái biểu mẫu, tới lúc Lưu mới yêu cầu server xóa ảnh.

## Thêm hoặc sửa mẫu
- Vị trí: [survey_edit_page.dart](<../cuoiki/survey_app/lib/pages/survey_edit_page.dart>) — dòng 8.
- Lớp: `SurveyEditPage`. Hàm cần đọc: `_load, _pickImage, _editQuestion, _save`.
- Đường đi: Admin → Thêm mẫu; hoặc Chi tiết mẫu → Sửa mẫu.
- Gọi tiếp: SurveyRepository.save → SurveyController.Add/Update → SurveyRules.ValidateQuestions.
- Dữ liệu liên quan: Surveys.QuestionsJson và file ảnh.

Một trang dùng cho thêm/sửa tùy widget.survey. Câu hỏi được sửa cục bộ trong _questions trước; bấm Lưu mẫu mới gửi toàn bộ lên API.

## Hộp thoại câu hỏi
- Vị trí: [survey_edit_page.dart](<../cuoiki/survey_app/lib/pages/survey_edit_page.dart>) — dòng 241.
- Lớp: `QuestionDialog`. Hàm cần đọc: `_QuestionDialogState._save`.
- Đường đi: Trong trang thêm/sửa mẫu → Thêm câu hỏi hoặc icon sửa câu hỏi.
- Gọi tiếp: Chưa gọi API riêng; trả Question qua Navigator.pop.
- Dữ liệu liên quan: Danh sách _questions trong bộ nhớ; sau đó vào Surveys.QuestionsJson.

Có bốn loại text/single/multiple/rating; lựa chọn nhập mỗi dòng một mục. Dialog nằm cuối file sửa mẫu, không có QuestionController riêng.

## Chi tiết mẫu và mẫu liên quan
- Vị trí: [survey_details_page.dart](<../cuoiki/survey_app/lib/pages/survey_details_page.dart>) — dòng 10.
- Lớp: `SurveyDetailsPage`. Hàm cần đọc: `_load, _loadRelated, _addPlan, _delete`.
- Đường đi: Bấm một mẫu ở danh sách hoặc mẫu liên quan.
- Gọi tiếp: SurveyRepository.details/related/delete; CampaignRepository.plan/putPlan.
- Dữ liệu liên quan: Surveys, Categories, CampaignItems và PlanItems.

Có ảnh, mô tả, câu hỏi và thêm kế hoạch. Mẫu đã dùng khóa nút sửa. Mẫu liên quan được tải riêng; lỗi phần này không làm mất toàn bộ nội dung chính.

## Kế hoạch triển khai
- Vị trí: [plan_page.dart](<../cuoiki/survey_app/lib/pages/plan_page.dart>) — dòng 8.
- Lớp: `PlanPage`. Hàm cần đọc: `_load, _target, _remove, _checkout`.
- Đường đi: Icon bảng kế hoạch tại AppBar trang chủ.
- Gọi tiếp: CampaignRepository.plan/putPlan/removePlan/checkout → PlanController.
- Dữ liệu liên quan: PlanItems → Campaigns và CampaignItems.

Dialog _TargetDialog cũng ở file này. _requestId tạo một lần khi mở trang để thử lại cùng lần tạo chiến dịch, không lưu bền vào SQLite như SubmissionId.

## Danh sách chiến dịch
- Vị trí: [campaign_list_page.dart](<../cuoiki/survey_app/lib/pages/campaign_list_page.dart>) — dòng 8.
- Lớp: `CampaignListPage`. Hàm cần đọc: `_load, _apply, _pickDate`.
- Đường đi: Trang chủ → Chiến dịch của tôi/Quản lý chiến dịch/Khảo sát đang mở.
- Gọi tiếp: CampaignRepository.getPage → CampaignController.Get.
- Dữ liệu liên quan: Campaigns và Members.

Một trang với biến open cho danh sách đang mở. Tên hiển thị theo admin/open; API mới là nơi quyết định dữ liệu được trả về theo quyền.

## Chi tiết chiến dịch
- Vị trí: [campaign_details_page.dart](<../cuoiki/survey_app/lib/pages/campaign_details_page.dart>) — dòng 9.
- Lớp: `CampaignDetailsPage`. Hàm cần đọc: `_load, _status`.
- Đường đi: Bấm chiến dịch; hoặc vừa tạo chiến dịch từ kế hoạch.
- Gọi tiếp: CampaignRepository.details/status → CampaignController.Details/Status.
- Dữ liệu liên quan: Campaigns, CampaignItems và Responses.

Nút trạng thái chỉ dành cho Admin. canManage do API trả về chỉ quyền xem kết quả cho owner/Admin, không cấp Member quyền đổi trạng thái.

## Trả lời khảo sát
- Vị trí: [response_page.dart](<../cuoiki/survey_app/lib/pages/response_page.dart>) — dòng 11.
- Lớp: `ResponsePage`. Hàm cần đọc: `_load, _store, _save, _submit`.
- Đường đi: Chiến dịch Active → Trả lời khảo sát; hoặc mở một nháp.
- Gọi tiếp: SurveyRepository.details; CampaignRepository.submit → CampaignController.Submit.
- Dữ liệu liên quan: response_drafts SQLite và Responses SQL Server.

Ưu tiên đọc nháp theo member_id/item_id; không có nháp mới tải mẫu. Trước khi gửi có _store; lỗi mạng giữ nháp để gửi lại cùng SubmissionId.

## Danh sách bản nháp
- Vị trí: [drafts_page.dart](<../cuoiki/survey_app/lib/pages/drafts_page.dart>) — dòng 9.
- Lớp: `DraftsPage`. Hàm cần đọc: `_load; onTap mở ResponsePage; nút xóa nháp`.
- Đường đi: Trang chủ → Bản nháp.
- Gọi tiếp: LocalDatabase.drafts/deleteDraft; không cần API để đọc danh sách nháp.
- Dữ liệu liên quan: response_drafts của tài khoản hiện tại.

Payload có bản mẫu để mở offline. Nháp không tự gửi; người dùng mở và bấm Gửi khi có mạng. Xóa nháp mất phần chưa gửi.

## Kết quả khảo sát
- Vị trí: [results_page.dart](<../cuoiki/survey_app/lib/pages/results_page.dart>) — dòng 6.
- Lớp: `ResultsPage`. Hàm cần đọc: `_load`.
- Đường đi: Chi tiết chiến dịch → Xem kết quả.
- Gọi tiếp: CampaignRepository.results → CampaignController.Results.
- Dữ liệu liên quan: Responses.AnswersJson và Surveys.QuestionsJson.

C# tổng hợp số lượt chọn và trung bình; Flutter trình bày và tính phần trăm theo tổng phản hồi. Chưa có xuất Excel/PDF hay biểu đồ phân tích chuyên sâu.

## Kết nối máy chủ
- Vị trí: [server_settings_page.dart](<../cuoiki/survey_app/lib/pages/server_settings_page.dart>) — dòng 6.
- Lớp: `ServerSettingsPage`. Hàm cần đọc: `_check`.
- Đường đi: Icon bánh răng tại LoginPage hoặc HomePage.
- Gọi tiếp: ApiService.checkServer/saveServer.
- Dữ liệu liên quan: Secure Storage khóa server_url; GET /api/health.

Lưu URL chỉ sau khi kiểm tra máy chủ phản hồi. Thay địa chỉ không tự triển khai server hay mở firewall. Mọi repository dùng cùng ApiService.baseUrl.
