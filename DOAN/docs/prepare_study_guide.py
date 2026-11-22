from pathlib import Path
import re
import csv
import json
import hashlib
import shutil
import os

DOAN = Path(__file__).resolve().parents[1]
OUT = DOAN / 'on_tap_va_giai_trinh_app'
OUT.mkdir(exist_ok=True)
APP = 'cuoiki/survey_app/lib/'
API = 'cuoiki/SurveyApi/'
checked_refs = []

def read(path): return (DOAN/path).read_text(encoding='utf-8-sig')
def put(name,text):
    path=OUT/name; path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text.strip()+'\n',encoding='utf-8')
def ref(path,needle=None,label=None):
    source=read(path)
    line=1
    if needle:
        assert needle in source,(path,needle)
        line=source[:source.index(needle)].count('\n')+1
    checked_refs.append((path,needle,line))
    rel=Path(os.path.relpath(DOAN/path,OUT)).as_posix()
    return f'[{label or Path(path).name}](<{rel}>) — dòng {line}'
def a(path,needle=None): return ref(APP+path,needle)
def b(path,needle=None): return ref(API+path,needle)

put('README.md','''
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
''')

put('01_tong_quan_va_thuat_ngu.md',f'''
# Tổng quan và thuật ngữ

## Cách giới thiệu ngắn

Ứng dụng hỗ trợ doanh nghiệp quản lý mẫu khảo sát, lập kế hoạch và triển khai chiến dịch để thu thập ý kiến. Người tham gia trả lời trên điện thoại; chủ chiến dịch hoặc Admin xem kết quả. Flutter Dart làm giao diện Android, REST API C# ASP.NET Core 10 xử lý nghiệp vụ, SQL Server lưu dữ liệu tập trung và SQLite lưu nháp trên điện thoại.

## Các khái niệm cần phân biệt

| Khái niệm | Ý nghĩa | Ví dụ |
| --- | --- | --- |
| Danh mục Category | Phân nhóm các mẫu | Nhân sự, Khách hàng, Thị trường |
| Mẫu Survey | Bộ câu hỏi có thể được đưa vào chiến dịch | Mức độ hài lòng của nhân viên |
| Câu hỏi Question | Một mục trong bộ câu hỏi | Bạn hài lòng với môi trường làm việc ở mức nào? |
| Kế hoạch Plan | Các mẫu một tài khoản đang chuẩn bị triển khai | Hai mẫu với mục tiêu lần lượt 20 và 30 phản hồi |
| Chiến dịch Campaign | Đợt triển khai đã tạo từ kế hoạch | Khảo sát nhân sự quý 4 |
| Chi tiết CampaignItem | Một mẫu cụ thể trong một chiến dịch | Mẫu hài lòng nhân viên trong chiến dịch quý 4 |
| Phản hồi Response | Một lần trả lời của tài khoản cho CampaignItem | Các đáp án của một người tham gia |
| Nháp Draft | Nội dung trả lời chưa gửi, lưu trên điện thoại | Câu trả lời đang nhập dở |

SurveyId không phải CampaignId. ItemId là mã dòng chi tiết chiến dịch, không phải vị trí câu hỏi. Cùng một mẫu có thể được triển khai trong nhiều chiến dịch; một người có thể trả lời ở mỗi chiến dịch nhưng không gửi hai lần cho cùng ItemId.

## Công nghệ và vai trò

| Thành phần | Nhiệm vụ trong app |
| --- | --- |
| Flutter/Dart | Widget, màn hình, trạng thái, gọi API và lưu nháp |
| HTTP REST/JSON | Trao đổi dữ liệu giữa điện thoại và máy chủ |
| multipart/form-data | Gửi cả thông tin biểu mẫu và file ảnh |
| C# ASP.NET Core 10 | Endpoint, xác thực, phân quyền và nghiệp vụ |
| Dapper | Ánh xạ kết quả SQL thành object; vẫn viết SQL trực tiếp |
| SQL Server | Nguồn dữ liệu tập trung cho các tài khoản |
| SQLite/sqflite | Database cục bộ để lưu và mở nháp |
| Flutter Secure Storage | Token, hồ sơ phiên và địa chỉ máy chủ |
| JWT | Token có chữ ký và thời hạn, mang mã người dùng và vai trò |
| BCrypt | Băm và xác minh mật khẩu, không giải mã mật khẩu |

Flutter có khả năng đa nền tảng, nhưng bản này chỉ được kiểm chứng triển khai trên Android. Không tự nói đã chạy iOS/web/Windows.

## Bốn nơi chứa dữ liệu

![Kiến trúc hệ thống](phu_luc/01_kien_truc_he_thong.png)

1. SQL Server: tài khoản, danh mục, mẫu, kế hoạch, chiến dịch và phản hồi.
2. SQLite: nháp trả lời theo tài khoản và ItemId.
3. Secure Storage: token, hồ sơ để mở lại app và server_url.
4. wwwroot/uploads trên máy chủ: file ảnh; SQL Server lưu đường dẫn ảnh.

## Đọc code từ đâu

- Điểm bắt đầu Flutter: {a('main.dart','void main()')}.
- Điểm bắt đầu API: {b('Program.cs','var builder')}.
- Nháp cục bộ: {a('local/local_database.dart','class LocalDatabase')}.
- Đầu mối hiểu đối tượng: {a('models/survey.dart','class Survey')} và {b('Api/Models/Survey.cs','public class Survey')}.
''')

# label, file, class, entry, methods, backend, data, explanation
screens=[
('Khởi động và khôi phục phiên','main.dart','SurveyApp','Mở app từ icon','main, _SessionPageState.build','SessionHelper.restore; chưa gọi API để xác thực lại ngay khi mở','SQLite mở database; Secure Storage đọc hồ sơ/token','WidgetsFlutterBinding khởi tạo plugin, mở database và đọc URL, sau đó runApp. FutureBuilder quyết định vào LoginPage hay HomePage. Hồ sơ cục bộ không thay thế kiểm tra quyền phía server.'),
('Đăng nhập và đăng ký','pages/login_page.dart','LoginPage','Mở app chưa có phiên; bấm Chưa có tài khoản? Đăng ký','_submit','MemberRepository.login/register → AuthController.Login/Register','Members và Roles; token/hồ sơ vào Secure Storage','Chỉ một file cho cả hai chế độ. Biến _register đổi giao diện. Đăng ký xong quay về chế độ đăng nhập, không tự tạo Admin.'),
('Trang chủ','pages/home_page.dart','HomePage','Đăng nhập thành công hoặc khôi phục hồ sơ','_open, _refreshPlan, _logout','CampaignRepository.plan; MemberRepository.logout','PlanItems; Secure Storage và nháp khi logout','Là khung trang chủ: hồ sơ, menu chức năng, icon kế hoạch/badge, kết nối và logout. Phần danh sách thực tế nằm trong SurveyListView.'),
('Danh sách mẫu tại trang chủ','pages/survey_list_view.dart','SurveyListView','Được HomePage nhúng vào body','_load, _details, _add','SurveyRepository.categories/getPage → CategoryController.Get, SurveyController.Get','Categories và Surveys','Đây là widget nội dung dùng trong trang chủ, không phải một route trang riêng. Tìm kiếm, lọc danh mục, phân trang và ảnh đều ở đây. _request tránh phản hồi cũ ghi đè lần tải mới.'),
('Đổi mật khẩu','pages/change_password_page.dart','ChangePasswordPage','Trang chủ → Đổi mật khẩu','_save','MemberRepository.changePassword → AuthController.ChangePassword','Members.PasswordHash và TokenVersion; xóa phiên/nháp cục bộ','Kiểm tra mật khẩu xác nhận tại Flutter; API kiểm tra mật khẩu hiện tại. Thành công yêu cầu đăng nhập lại và app xóa nháp của tài khoản.'),
('Thành viên và vai trò','pages/member_page.dart','MemberPage','Menu Admin → Thành viên và vai trò','_load, _edit, _delete','MemberRepository.getMembers/getRoles/updateMember/deleteMember → MemberController','Members và Roles','Dialog sửa viết ngay trong _edit bằng DialogRoute và StatefulBuilder; không có trang role riêng. Không cho sửa/xóa chính mình.'),
('Danh mục và ảnh','pages/category_page.dart','CategoryPage','Menu Admin → Danh mục','_load, _edit, _delete; _CategoryDialogState._pickImage/_save','SurveyRepository.categories/saveCategory/deleteCategory → CategoryController','Categories và wwwroot/uploads','Danh sách và dialog thêm/sửa chung file. Bỏ ảnh chỉ thay trạng thái biểu mẫu, tới lúc Lưu mới yêu cầu server xóa ảnh.'),
('Thêm hoặc sửa mẫu','pages/survey_edit_page.dart','SurveyEditPage','Admin → Thêm mẫu; hoặc Chi tiết mẫu → Sửa mẫu','_load, _pickImage, _editQuestion, _save','SurveyRepository.save → SurveyController.Add/Update → SurveyRules.ValidateQuestions','Surveys.QuestionsJson và file ảnh','Một trang dùng cho thêm/sửa tùy widget.survey. Câu hỏi được sửa cục bộ trong _questions trước; bấm Lưu mẫu mới gửi toàn bộ lên API.'),
('Hộp thoại câu hỏi','pages/survey_edit_page.dart','QuestionDialog','Trong trang thêm/sửa mẫu → Thêm câu hỏi hoặc icon sửa câu hỏi','_QuestionDialogState._save','Chưa gọi API riêng; trả Question qua Navigator.pop','Danh sách _questions trong bộ nhớ; sau đó vào Surveys.QuestionsJson','Có bốn loại text/single/multiple/rating; lựa chọn nhập mỗi dòng một mục. Dialog nằm cuối file sửa mẫu, không có QuestionController riêng.'),
('Chi tiết mẫu và mẫu liên quan','pages/survey_details_page.dart','SurveyDetailsPage','Bấm một mẫu ở danh sách hoặc mẫu liên quan','_load, _loadRelated, _addPlan, _delete','SurveyRepository.details/related/delete; CampaignRepository.plan/putPlan','Surveys, Categories, CampaignItems và PlanItems','Có ảnh, mô tả, câu hỏi và thêm kế hoạch. Mẫu đã dùng khóa nút sửa. Mẫu liên quan được tải riêng; lỗi phần này không làm mất toàn bộ nội dung chính.'),
('Kế hoạch triển khai','pages/plan_page.dart','PlanPage','Icon bảng kế hoạch tại AppBar trang chủ','_load, _target, _remove, _checkout','CampaignRepository.plan/putPlan/removePlan/checkout → PlanController','PlanItems → Campaigns và CampaignItems','Dialog _TargetDialog cũng ở file này. _requestId tạo một lần khi mở trang để thử lại cùng lần tạo chiến dịch, không lưu bền vào SQLite như SubmissionId.'),
('Danh sách chiến dịch','pages/campaign_list_page.dart','CampaignListPage','Trang chủ → Chiến dịch của tôi/Quản lý chiến dịch/Khảo sát đang mở','_load, _apply, _pickDate','CampaignRepository.getPage → CampaignController.Get','Campaigns và Members','Một trang với biến open cho danh sách đang mở. Tên hiển thị theo admin/open; API mới là nơi quyết định dữ liệu được trả về theo quyền.'),
('Chi tiết chiến dịch','pages/campaign_details_page.dart','CampaignDetailsPage','Bấm chiến dịch; hoặc vừa tạo chiến dịch từ kế hoạch','_load, _status','CampaignRepository.details/status → CampaignController.Details/Status','Campaigns, CampaignItems và Responses','Nút trạng thái chỉ dành cho Admin. canManage do API trả về chỉ quyền xem kết quả cho owner/Admin, không cấp Member quyền đổi trạng thái.'),
('Trả lời khảo sát','pages/response_page.dart','ResponsePage','Chiến dịch Active → Trả lời khảo sát; hoặc mở một nháp','_load, _store, _save, _submit','SurveyRepository.details; CampaignRepository.submit → CampaignController.Submit','response_drafts SQLite và Responses SQL Server','Ưu tiên đọc nháp theo member_id/item_id; không có nháp mới tải mẫu. Trước khi gửi có _store; lỗi mạng giữ nháp để gửi lại cùng SubmissionId.'),
('Danh sách bản nháp','pages/drafts_page.dart','DraftsPage','Trang chủ → Bản nháp','_load; onTap mở ResponsePage; nút xóa nháp','LocalDatabase.drafts/deleteDraft; không cần API để đọc danh sách nháp','response_drafts của tài khoản hiện tại','Payload có bản mẫu để mở offline. Nháp không tự gửi; người dùng mở và bấm Gửi khi có mạng. Xóa nháp mất phần chưa gửi.'),
('Kết quả khảo sát','pages/results_page.dart','ResultsPage','Chi tiết chiến dịch → Xem kết quả','_load','CampaignRepository.results → CampaignController.Results','Responses.AnswersJson và Surveys.QuestionsJson','C# tổng hợp số lượt chọn và trung bình; Flutter trình bày và tính phần trăm theo tổng phản hồi. Chưa có xuất Excel/PDF hay biểu đồ phân tích chuyên sâu.'),
('Kết nối máy chủ','pages/server_settings_page.dart','ServerSettingsPage','Icon bánh răng tại LoginPage hoặc HomePage','_check','ApiService.checkServer/saveServer','Secure Storage khóa server_url; GET /api/health','Lưu URL chỉ sau khi kiểm tra máy chủ phản hồi. Thay địa chỉ không tự triển khai server hay mở firewall. Mọi repository dùng cùng ApiService.baseUrl.'),
]
lines=['# Bản đồ màn hình và file code', '', 'Số dòng đi cùng tên lớp để tra nhanh; các hàm trùng _load/_save cần tìm trong đúng lớp State. Đăng ký, dialog và widget nhúng được ghi riêng để tránh nhầm thành file không tồn tại.', '', '| Màn hình hoặc thành phần | File và lớp | Cách mở |', '| --- | --- | --- |']
for title,path,cls,entry,*_ in screens: lines.append(f'| {title} | {a(path,"class "+cls)}; `{cls}` | {entry} |')
for title,path,cls,entry,methods,backend,data,explanation in screens:
    lines += ['',f'## {title}',f'- Vị trí: {a(path,"class "+cls)}.',f'- Lớp: `{cls}`. Hàm cần đọc: `{methods}`.',f'- Đường đi: {entry}.',f'- Gọi tiếp: {backend}.',f'- Dữ liệu liên quan: {data}.','',explanation]
put('02_ban_do_man_hinh.md','\n'.join(lines))
with (OUT/'ban_do_man_hinh.csv').open('w',newline='',encoding='utf-8-sig') as f:
    w=csv.writer(f);w.writerow(['Màn hình','File tính từ DOAN','Lớp','Cách mở','Hàm chính','Gọi tiếp','Dữ liệu','Giải thích']);w.writerows([[t,APP+p,c,e,m,bk,d,x] for t,p,c,e,m,bk,d,x in screens])

put('03_hieu_ma_flutter.md',f'''
# Hiểu cấu trúc và mã Flutter

## Cách tách thư mục

`models` mô tả dữ liệu, `pages` dựng giao diện và xử lý thao tác, `repositories` chuyển thao tác thành HTTP request, `services` lo kết nối/phiên chung, `local` thao tác SQLite và `widgets` chứa thành phần dùng lại. Cách tổ chức học từ trek_bikes_app; không gọi đây là một triển khai Clean Architecture đầy đủ hoặc một dự án dùng Bloc/Provider vì app không dùng các thư viện quản lý trạng thái đó.

## Luồng khởi động

{a('main.dart','void main()')}: ensureInitialized → LocalDatabase.open → ApiService.initialize → runApp. SurveyApp dựng MaterialApp và SafeArea. _SessionPage đọc SessionHelper.restore bằng FutureBuilder. Đọc xong hồ sơ thì vào HomePage hoặc LoginPage.

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

HomePage._open quay lại sẽ tăng _revision để tái tạo SurveyListView rồi cập nhật badge. SurveyListView._details tải lại sau khi quay về từ chi tiết. Đọc tại {a('pages/home_page.dart','Future<void> _open')} và {a('pages/survey_list_view.dart','Future<void> _details')}.

## Model và JSON

- {a('models/member.dart','class Member')}: hồ sơ tài khoản, role và trạng thái hiển thị.
- {a('models/survey.dart','class Category')}: Category và imagePath nullable; danh mục cũ có thể không có ảnh.
- Cùng file chứa Question, Survey, PlanItem, Campaign, CampaignItem và PageData. fromMap nhận dữ liệu camelCase từ JSON. Survey.toMap và Question.toMap phục vụ nháp/upload câu hỏi.
- jsonEncode chuyển object/map thành chuỗi JSON; jsonDecode làm ngược lại. Không dùng chung khái niệm với encryption hoặc hash.

## Ba repository Dart

| File | Nhóm hàm |
| --- | --- |
| {a('repositories/member_repository.dart','class MemberRepository')} | đăng ký, đăng nhập, đổi mật khẩu, logout, thành viên và role |
| {a('repositories/survey_repository.dart','class SurveyRepository')} | danh mục, ảnh danh mục, mẫu, chi tiết và mẫu liên quan |
| {a('repositories/campaign_repository.dart','class CampaignRepository')} | kế hoạch, tạo chiến dịch, danh sách, trạng thái, gửi phản hồi và kết quả |

MemberRepository._post là đường HTTP riêng cho đăng ký/đăng nhập không cần token. Các lời gọi nghiệp vụ còn lại dùng ApiService.request; upload dùng MultipartRequest và ApiService.upload. Các repository đều lấy baseUrl hiện tại từ ApiService, nên đổi Wi-Fi không cần sửa mỗi file.

## ApiService và SessionHelper

{a('services/api_service.dart','class ApiService')}: normalizeUrl kiểm tra URL gốc HTTP/HTTPS; initialize đọc URL lưu; checkServer gọi health không gửi JWT; saveServer ghi URL; request thêm Bearer token; upload gửi multipart; decode chuyển HTTP lỗi thành exception; imageUrl ghép đường dẫn ảnh với máy chủ.

Không diễn giải timeout là một giá trị duy nhất cho toàn bộ app: kiểm tra health 8 giây; auth _post 15 giây; request và stream phản hồi có timeout từng bước 20 giây; upload từng bước 30 giây. Các giá trị là giới hạn chờ từng lời gọi/bước, không đảm bảo tổng thời gian chỉ bằng một số đó.

{a('services/session_helper.dart','class SessionHelper')}: save lưu member/token; restore đọc hồ sơ; token lấy token; clear chỉ xóa token/member. server_url không bị xóa bởi logout. Nháp được dọn riêng ở các trang khi logout/đổi mật khẩu, không nằm trong SessionHelper.clear.

## Widget dùng lại

- {a('widgets/common.dart','class PageButtons')}: nút trước/sau và tổng kết quả, mặc định giao diện dùng 10 mục/trang.
- Cùng file có errorText, showMessage và confirmAction.
- {a('widgets/category_image.dart','class CategoryImage')}: ảnh danh mục hoặc icon thư mục khi thiếu/lỗi ảnh.
- ListView/SingleChildScrollView giúp cuộn khi bàn phím chiếm chiều cao; không tắt resizeToAvoidBottomInset để che lỗi layout.

## SQLite

{a('local/local_database.dart','class LocalDatabase')}: open tạo database phiên bản 2; onUpgrade thêm response_drafts cho bản cũ. saveDraft dùng ConflictAlgorithm.replace trên khóa ghép để cập nhật nháp hiện có. draft/drafts đọc riêng theo member; deleteDraft xóa một nháp; clearDrafts xóa của một tài khoản. API không đọc database SQLite từ điện thoại.
''')

put('04_hieu_api_csharp.md',f'''
# Hiểu API C# và các lớp phía máy chủ

## Program và Dependency Injection

{b('Program.cs','var builder')}: đọc cấu hình, đăng ký Controllers, SiteProvider, ImageService, xác thực JWT và authorization. API Development có khóa local bền vững nếu chưa cấu hình secret; Production yêu cầu secret riêng. Không mở hoặc trình chiếu giá trị khóa khi giải trình.

AddScoped tạo SiteProvider theo vòng đời request. {b('Api/Models/SiteProvider.cs','public sealed class SiteProvider')} giữ SqlConnection và khởi tạo lười các repository bằng ??=. Kết thúc scope sẽ Dispose connection. BaseRepository giữ IDbConnection để các repository dùng Dapper.

UseAuthentication xác định danh tính từ token; UseAuthorization kiểm tra quyền. OnTokenValidated đọc thành viên hiện tại để so IsActive, TokenVersion và role. UseStaticFiles phục vụ ảnh; UseExceptionHandler trả thông báo lỗi chung khi chưa xử lý tại controller. GET /api/health chỉ kiểm tra tiến trình trả lời, không chứng minh SQL Server hoặc mọi nghiệp vụ đều đang khỏe.

## Controller và repository khác nhau

Controller nhận HTTP, nhận model đầu vào, kiểm tra quyền/điều kiện, chọn HTTP status và gọi repository/service. Repository thực hiện SQL và transaction. Model C# mô tả request/response và validation attributes; không tự lưu dữ liệu chỉ vì đã tạo object.

| Controller | Repository/service gọi tiếp | Nghiệp vụ |
| --- | --- | --- |
| {b('Api/Controllers/AuthController.cs','public class AuthController')} | MemberRepository | Register, Login, Me, ChangePassword, Logout |
| {b('Api/Controllers/MemberController.cs','public class MemberController')} | MemberRepository | Get, Roles, Update, Delete; toàn controller chỉ Admin |
| {b('Api/Controllers/CategoryController.cs','public class CategoryController')} | CategoryRepository và ImageService | Get, Add, Update, Delete; thêm/sửa multipart |
| {b('Api/Controllers/SurveyController.cs','public class SurveyController')} | SurveyRepository, SurveyRules, ImageService | Get, Details, Related, Add, Update, Delete |
| {b('Api/Controllers/PlanController.cs','public class PlanController')} | CampaignRepository | GetPlan, PutPlan, RemovePlan, Checkout |
| {b('Api/Controllers/CampaignController.cs','public class CampaignController')} | CampaignRepository, SurveyRepository, SurveyRules gián tiếp | danh sách, chi tiết, trạng thái, phản hồi, kết quả |

## Model và quy tắc

{b('Api/Models/Member.cs','public class Member')}: Member, LoginModel, RegisterModel, ChangePasswordModel, UpdateMemberModel. RegisterModel kế thừa dữ liệu đăng nhập và thêm FullName. PublicMember trong AuthController không trả PasswordHash cho app.

{b('Api/Models/Survey.cs','public class Category')}: Category, CategoryForm, Survey, Question, SurveyForm, PageResult, TargetModel, CheckoutModel, ResponseModel, StatusModel, PlanItem, Campaign và CampaignItem. Không có file riêng cho mỗi model.

[Required], [StringLength], [Range], [MaxLength], [RegularExpression] hỗ trợ validation từ model binding/[ApiController]. SurveyRules bổ sung quy tắc khó thể hiện bằng attribute: loại câu hỏi, lựa chọn trùng, câu bắt buộc và kiểu giá trị đáp án.

## Dapper và SQL

QueryAsync<T> trả nhiều dòng; QuerySingleAsync<T> yêu cầu một dòng; QuerySingleOrDefaultAsync<T> cho phép không có dòng; ExecuteAsync dùng INSERT/UPDATE/DELETE không cần object kết quả; ExecuteScalarAsync lấy một giá trị như COUNT. OUTPUT INSERTED.Id lấy mã bản ghi vừa tạo.

Các tham số @id, @memberId, @search được truyền riêng qua object; không ghép trực tiếp nội dung người dùng thành SQL. Có ghép các đoạn SQL cố định để dùng lại WHERE, nhưng giá trị người dùng vẫn là tham số. LIKE hiện vẫn có ý nghĩa wildcard SQL; không khẳng định đã escape mọi ký tự tìm kiếm.

## HTTP cần nhớ

| Mã | Tình huống thường gặp trong app |
| --- | --- |
| 200 | Đăng nhập, cập nhật, danh sách, gửi phản hồi; tạo chiến dịch hiện cũng trả 200 |
| 201 | Đăng ký, thêm danh mục hoặc mẫu thành công |
| 400 | Model, khoảng ngày, câu hỏi hoặc câu trả lời không hợp lệ |
| 401 | Sai đăng nhập; thiếu token, token hết hạn/bị thu hồi hoặc tài khoản bị khóa |
| 403 | Đã xác thực nhưng không đủ quyền, như Member sửa danh mục |
| 404 | Không tồn tại mẫu, danh mục hoặc chi tiết yêu cầu |
| 409 | Email/tên trùng, mẫu đã dùng, chuyển trạng thái sai hoặc phản hồi xung đột |
| 500 | Lỗi chưa xử lý được như lỗi máy chủ/database; client nhận thông báo chung |

## Phân trang và ngày

Page từ 1 đến 100000, pageSize từ 1 đến 50 ở các endpoint danh sách có phân trang. OFFSET = (page − 1) × pageSize; FETCH NEXT pageSize ROWS ONLY. Total là số bản ghi phù hợp điều kiện, không phải số trang. Ở app mỗi trang 10 mục; số trang = làm tròn lên Total/10, tối thiểu hiển thị 1.

CampaignController.Get đổi ngày Việt Nam sang UTC: đầu ngày fromDate được lấy bao gồm; đầu ngày sau toDate là mốc loại trừ. Ví dụ ngày 02/01/2026 giờ Việt Nam tương ứng từ 01/01 17:00 UTC đến trước 02/01 17:00 UTC. SQL dùng >= start và < end, không cộng thời gian cuối ngày bằng 23:59:59 thủ công.
''')

flows=[
('Đăng ký','LoginPage._submit với _register=true → MemberRepository.register/_post → POST /api/auth/register → AuthController.Register → MemberRepository.Add → Members','Họ tên/email/mật khẩu kiểm tra cả client và server. Email được trim và chuẩn hóa lowercase. SQL chọn RoleId của Member; client không tự chọn Admin. BCrypt.HashPassword lưu hash. Email UNIQUE chống trùng; lỗi SQL 2601/2627 trả 409.'),
('Đăng nhập','LoginPage._submit → MemberRepository.login/_post → POST /api/auth/login → AuthController.Login → FindByEmail → BCrypt.Verify → tạo JWT → SessionHelper.save → HomePage','JWT có NameIdentifier, Role và version, hết hạn sau 8 giờ. Mật khẩu không đi trong claims, PasswordHash không trả về hồ sơ công khai. Server kiểm tra IsActive trước khi cấp token.'),
('Đổi mật khẩu hoặc logout','ChangePasswordPage._save hoặc HomePage._logout → MemberRepository → AuthController → MemberRepository cập nhật TokenVersion','Đổi mật khẩu: kiểm tra current, khác mật khẩu cũ, update hash kèm điều kiện oldHash và tăng version. Logout online tăng version, làm các token cũ của tài khoản bị từ chối. Flutter xóa phiên và nháp theo tài khoản. Logout offline chỉ xử lý cục bộ, chưa thu hồi được các phiên khác.'),
('Thêm danh mục có ảnh','CategoryPage._edit → _CategoryDialogState._pickImage/_save → SurveyRepository.saveCategory → POST /api/categories multipart → CategoryController.Add → ImageService.Save → CategoryRepository.Add','Ảnh tùy chọn. API kiểm tra PNG/JPEG và dung lượng, lưu tên GUID; SQL chỉ nhận đường dẫn. Nếu SQL ghi lỗi sau khi đã upload, finally xóa file mới. Thêm không có ảnh thì ImagePath NULL.'),
('Thay, bỏ hoặc xóa ảnh danh mục','Dialog _save → PUT /api/categories/{id} → CategoryController.Update → CategoryRepository.Update → commit → ImageService.Delete(old)','Không chọn ảnh mới và không RemoveImage: giữ cũ. RemoveImage: đặt NULL; chọn ảnh mới: dùng đường dẫn mới. Xóa file cũ sau khi transaction ghi thành công. Xóa danh mục dùng Delete; FK chặn nếu còn mẫu, lúc đó file cũ giữ nguyên.'),
('Thêm mẫu và câu hỏi','SurveyEditPage._editQuestion → QuestionDialog._save → cập nhật _questions → SurveyEditPage._save → SurveyRepository.save → SurveyController.Add → SurveyRules.ValidateQuestions → ImageService.Save → SurveyRepository.Add','Dialog chỉ trả object Question, chưa có API lưu câu hỏi riêng. Toàn bộ danh sách được jsonEncode vào questionsJson của multipart. Mẫu mới phải có ảnh. Server giới hạn 1–50 câu hỏi, mã dương không trùng, loại hợp lệ và đáp án 2–20 mục cho câu chọn.'),
('Tìm mẫu và xem liên quan','SurveyListView._load → SurveyRepository.categories/getPage → GET categories/surveys → SurveyRepository C#.GetPage; SurveyDetailsPage._loadRelated → GET surveys/{id}/related','SQL lọc theo danh mục và tên trước khi COUNT và OFFSET/FETCH. Related tìm danh mục của mẫu gốc, lọc SurveyId khác mẫu gốc, xếp mã giảm dần. Không phải thuật toán gợi ý bằng AI.'),
('Thêm kế hoạch, sửa chỉ tiêu và badge','SurveyDetailsPage._addPlan → CampaignRepository.plan/putPlan → PlanController.Put → CampaignRepository.PutPlan → PlanItems; HomePage._refreshPlan lấy plan.length','Khóa ghép MemberId+SurveyId chỉ một dòng mỗi mẫu trên mỗi tài khoản. PutPlan dùng transaction và upsert IF EXISTS; TargetCount giới hạn 1–100000. Badge là số mẫu, không là tổng chỉ tiêu. MemberId lấy từ JWT ở server.'),
('Tạo chiến dịch','PlanPage._checkout → CampaignRepository.checkout → POST /api/plan/checkout → PlanController.Checkout → CampaignRepository.Checkout → trả CampaignId → CampaignDetailsPage','Tìm chiến dịch cùng MemberId/RequestId trước; đã có trả mã cũ. Chưa có: đọc kế hoạch, từ chối trống, giữ khóa các mẫu, INSERT Campaigns và CampaignItems, DELETE PlanItems, commit. Các bước tạo và xóa kế hoạch nằm cùng transaction.'),
('Tìm, lọc và đổi trạng thái chiến dịch','CampaignListPage._load → getPage → CampaignController.Get → CampaignRepository.GetPage; CampaignDetailsPage._status → Status → SetStatus','Điều kiện quyền nằm trong WHERE trước tìm kiếm. open=true chỉ Active; open=false Member chỉ của mình, Admin toàn bộ. Status chỉ Admin, SQL WHERE kiểm tra trạng thái hiện tại; yêu cầu chuyển trái luồng không cập nhật dòng.'),
('Mở nháp và gửi phản hồi','ResponsePage._load → LocalDatabase.draft; không có nháp thì SurveyRepository.details. _submit → kiểm tra bắt buộc → xác nhận → _store → CampaignRepository.submit → CampaignController.Submit → CampaignRepository.Submit','API giữ khóa Campaigns, tìm ItemId thuộc chiến dịch, kiểm tra phản hồi trước đó, trạng thái, chỉ tiêu và SurveyRules.ValidateAnswers. INSERT Responses rồi commit. Thành công client xóa nháp, lỗi giữ nháp. Cùng SubmissionId gửi lại trả thành công nhưng không ghi thêm; khác mã trên cùng ItemId/MemberId bị chặn.'),
('Xem kết quả','CampaignDetailsPage → ResultsPage._load → CampaignRepository.results → GET .../results → CampaignController.Results → CampaignRepository.Answers + SurveyRepository.Find','API kiểm tra owner/Admin; đọc JSON phản hồi theo ItemId và câu hỏi theo mẫu. Text lấy nội dung không trống; option đếm số lần chọn; rating tính trung bình các giá trị số. Flutter hiển thị và tính phần trăm số chọn trên tổng phản hồi, nên câu nhiều lựa chọn có thể cộng hơn 100%.'),
('Lưu kết nối Wi-Fi','ServerSettingsPage._check → ApiService.normalizeUrl/checkServer → GET /api/health không JWT → saveServer → Secure Storage server_url','Không có khóa bí mật trong kiểm tra URL. Địa chỉ áp dụng cả đăng nhập, nghiệp vụ và upload. Bản release không phụ thuộc Flutter debugger, nhưng dữ liệu online vẫn phụ thuộc máy tính chạy API/SQL Server. IP đổi thì cập nhật trong app.'),
]
lines=['# Theo dõi từng chức năng từ giao diện tới dữ liệu','','![Luồng nghiệp vụ](phu_luc/03_luong_nghiep_vu.png)','','Cách dùng: mở Bản đồ màn hình để tới file Dart, sau đó mở các file C# theo chuỗi dưới. Repository Dart gọi HTTP; repository C# thực hiện SQL — hai lớp cùng tên nhưng khác vai trò.']
for i,(title,chain,notes) in enumerate(flows,1): lines += ['',f'## {i} {title}',f'**Chuỗi xử lý:** {chain}.','',notes]
put('05_luong_xu_ly_tung_chuc_nang.md','\n'.join(lines))

put('06_co_so_du_lieu_va_json.md',f'''
# Cơ sở dữ liệu và JSON

## Tám bảng SQL Server

![Quan hệ SQL Server](phu_luc/02_erd_sql_server.png)

| Bảng | Khóa và trường cần nhớ | Ý nghĩa |
| --- | --- | --- |
| Roles | RoleId PK; RoleName UNIQUE | Admin/Member cố định |
| Members | MemberId PK; RoleId FK; Email UNIQUE; FullName, PasswordHash, CreatedAt, IsActive, TokenVersion | Tài khoản và phiên |
| Categories | CategoryId PK; CategoryName UNIQUE; Description, ImagePath nullable | Nhóm mẫu khảo sát |
| Surveys | SurveyId PK; CategoryId FK; Title, Description, ImagePath, QuestionsJson, CreatedAt | Mẫu và bộ câu hỏi |
| PlanItems | PK ghép MemberId+SurveyId, cả hai FK; TargetCount | Kế hoạch đang chuẩn bị |
| Campaigns | CampaignId PK; MemberId FK; Title, Status, RequestId, CreatedAt; UNIQUE MemberId+RequestId | Chiến dịch |
| CampaignItems | ItemId PK; CampaignId FK, SurveyId FK; TargetCount; UNIQUE CampaignId+SurveyId | Mẫu trong đợt triển khai |
| Responses | ResponseId PK; ItemId FK, MemberId FK; SubmissionId UNIQUE; AnswersJson, CreatedAt; UNIQUE ItemId+MemberId | Phản hồi |

Quan hệ: Roles 1–N Members; Categories 1–N Surveys; Members 1–N Campaigns; Campaigns 1–N CampaignItems; Surveys 1–N CampaignItems. Members và Surveys liên hệ nhiều–nhiều qua PlanItems. Responses nối người tham gia với CampaignItem.

Không có bảng Orders, Products, Carts trong database đồ án này. Không có bảng Questions hay Answers riêng: câu hỏi và câu trả lời lưu JSON. Xem {b('Database/004_surveys_campaigns.sql','CREATE TABLE Surveys')} và {b('Database/005_category_images.sql','ALTER TABLE Categories')}.

## SQLite phiên bản 2

{a('local/local_database.dart','static Future<Database> open')} mở business_survey.db trên điện thoại. Bảng response_drafts là nơi lưu hiện tại, PK(member_id,item_id). Các trường campaign_id, payload_json và updated_at giúp mở lại đúng bản nháp. survey_drafts là bảng cũ giữ để tương thích và được dọn khi clearDrafts; luồng trả lời hiện tại không lưu vào bảng đó.

SQLite không có FK trực tiếp sang SQL Server. Các id trùng là tham chiếu nghiệp vụ; server luôn kiểm tra lại khi gửi. Token, member và server_url không nằm trong hai bảng này, chúng ở Secure Storage. Nháp SQLite hiện không có cơ chế mã hóa database riêng được triển khai trong code.

## Ví dụ JSON để hiểu

Các số và nội dung dưới đây là ví dụ giả lập để đọc cấu trúc, không phải dữ liệu được tạo thêm trong app.

QuestionsJson trong một Survey:

```json
[
  {{"id":1,"title":"Góp ý","type":"text","required":true,"options":[]}},
  {{"id":2,"title":"Bạn hài lòng?","type":"single","required":true,"options":["Có","Không"]}},
  {{"id":3,"title":"Yếu tố quan tâm","type":"multiple","required":false,"options":["Giá","Chất lượng"]}},
  {{"id":4,"title":"Đánh giá","type":"rating","required":true,"options":[]}}
]
```

Body gửi phản hồi:

```json
{{
  "submissionId":"11111111-1111-4111-8111-111111111111",
  "answers":{{"1":"Tốt","2":"Có","3":["Giá","Chất lượng"],"4":5}}
}}
```

Ở Responses chỉ AnswersJson lưu map answers, còn SubmissionId là cột riêng. Trong response_drafts.payload_json lưu object gồm survey (một bản nội dung mẫu), answers và submissionId. Đây là lý do đã có nháp thì mở mẫu mà không cần tải lại nội dung từ API.

## Truy vấn minh họa an toàn để giải thích

```sql
-- Chỉ đọc cấu trúc/quan hệ, không sửa dữ liệu.
SELECT c.CampaignId, c.Title, i.ItemId, s.Title AS SurveyTitle, i.TargetCount
FROM Campaigns c
JOIN CampaignItems i ON i.CampaignId=c.CampaignId
JOIN Surveys s ON s.SurveyId=i.SurveyId;

SELECT ItemId, COUNT(*) AS ResponseCount
FROM Responses GROUP BY ItemId;
```

Không chiếu SELECT PasswordHash hoặc dữ liệu cá nhân khi giải trình. Muốn chỉ dữ liệu nháp, mở LocalDatabase và Payload mẫu thay vì đưa token thật vào báo cáo.

## Thứ tự tạo database

001_initial.sql → 002_member_management.sql → 004_surveys_campaigns.sql → 005_category_images.sql. File 003_first_admin.sql là bước cấp Admin thủ công cho email đã đăng ký, không phải migration tự động. Tên database BusinessSurvey, khác database của hai dự án tham khảo.
''')

def excerpt(path,needle,count,lang,explanation):
    lines=read(path).splitlines()
    start=next(i for i,v in enumerate(lines) if needle in v)
    end=min(start+count,len(lines))
    return f'{ref(path,needle)}. Đoạn trích dòng {start+1} đến {end}; nếu kết thúc giữa hàm, mở file để xem phần còn lại.\n\n```{lang}\n'+ '\n'.join(lines[start:end])+'\n```\n\n'+explanation

sections=[
 ('setState và mounted',APP+'pages/survey_list_view.dart','final request = ++_request;',30,'dart','_request tăng theo mỗi lần tải. Chỉ request mới nhất còn hiệu lực mới ghi state; mounted bảo vệ khi trang đã đóng. Cờ busy/lỗi điều khiển giao diện, không thay cho quyền server.'),
 ('Multipart ảnh danh mục',APP+'repositories/survey_repository.dart','static Future<void> saveCategory(',35,'dart','URI dùng baseUrl đang cấu hình. Header Bearer xác thực. fields là tên/mô tả/cờ bỏ ảnh, files là dữ liệu ảnh. Không jsonEncode file ảnh thành chuỗi thường.'),
 ('Lưu nháp SQLite',APP+'local/local_database.dart','static Future<void> saveDraft(',18,'dart','insert vào response_drafts với ConflictAlgorithm.replace: trùng khóa ghép thì thay bản nháp. memberId và itemId phân biệt dữ liệu; mỗi lần lưu tạo lại thời gian cập nhật.'),
 ('Lưu payload nháp',APP+'pages/response_page.dart','Future<void> _store()',11,'dart','Nội dung mẫu, map đáp án và mã gửi được lưu cùng nhau. Có bản mẫu mới mở nháp offline; giữ mã gửi mới thử lại an toàn khi server đã nhận nhưng client chưa nhận được phản hồi.'),
 ('Đăng ký ép vai trò Member',API+'Api/Models/MemberRepository.cs','public Task<int> Add(',8,'csharp','RoleId lấy bằng truy vấn RoleName Member, không tin role client gửi. Email lowercase/trim; BCrypt tạo hash. SQL parameter tách giá trị khỏi câu lệnh.'),
 ('Phát hành JWT',API+'Api/Controllers/AuthController.cs','var expires =',11,'csharp','JWT sống 8 giờ, có id, role và version. Chữ ký HMAC SHA256 dùng secret của server. Payload JWT không tự được mã hóa; không thêm mật khẩu vào claims.'),
 ('Kiểm tra phiên mỗi request',API+'Program.cs','OnTokenValidated =',15,'csharp','Sau khi middleware kiểm tra chữ ký/thời hạn, app đọc trạng thái thành viên từ DB. Khóa tài khoản, tăng TokenVersion hoặc đổi role làm token cũ thất bại mà không phải chờ hết 8 giờ.'),
 ('Thay ảnh chỉ xóa cũ sau khi lưu',API+'Api/Controllers/CategoryController.cs','public async Task<IActionResult> Update(',18,'csharp','Update lưu ảnh mới rồi gọi repository ghi dữ liệu. Sau khi repository commit, path=null để finally không xóa ảnh mới đã dùng, rồi xóa old. Khi ghi lỗi, path vẫn giữ ảnh mới nên finally dọn file mới. Tên trùng không làm mất ảnh cũ.'),
 ('Khóa mẫu khi sửa',API+'Api/Models/SurveyRepository.cs','public async Task<string?> Update(',22,'csharp','Serializable và khóa bản ghi phối hợp với bước checkout để không sửa nội dung đúng lúc mẫu được triển khai. Kiểm tra CampaignItems trước UPDATE; không chỉ disable nút Sửa trên Flutter.'),
 ('Tạo chiến dịch không trùng',API+'Api/Models/CampaignRepository.cs','public async Task<int> Checkout(',26,'csharp','Tìm RequestId cũ trước, đọc kế hoạch, chèn campaign/items và xóa plan trong một transaction. Commit ở cuối file hàm. Có lỗi trước commit thì rollback khi Dispose, tránh tạo dở chiến dịch hoặc làm mất kế hoạch.'),
 ('Gửi phản hồi và kiểm tra trước đó',API+'Api/Models/CampaignRepository.cs','public async Task Submit(',27,'csharp','Giữ khóa chiến dịch, kiểm tra ItemId thuộc chiến dịch, phản hồi cũ, status, mục tiêu và đáp án rồi INSERT. Cùng SubmissionId là retry thành công, khác mã mà đã có phản hồi là xung đột. Luồng này xử lý yêu cầu đồng thời tại server.'),
 ('Kiểm tra từng loại câu trả lời',API+'Api/Models/SurveyRules.cs','public static void ValidateAnswers(',26,'csharp','JsonElement cho biết kiểu dữ liệu thực nhận. Không nhận câu hỏi lạ, đánh giá phải số nguyên 1–5, chọn nhiều không lặp và chỉ chứa lựa chọn trong mẫu. Không tin validation Flutter là đủ.'),
]
lines=['# Đoạn code thật cần giải thích','','Các đoạn dưới lấy trực tiếp từ mã nguồn khi tạo tài liệu. Mục tiêu là hiểu, không học thuộc. Tên phương thức là cách tìm bền vững hơn số dòng. Không có khóa hoặc mật khẩu thật trong các đoạn trích.']
for title,path,needle,count,lang,explanation in sections:
    lines += ['',f'## {title}',excerpt(path,needle,count,lang,explanation)]
put('07_doan_code_can_giai_thich.md','\n'.join(lines))

put('08_phan_quyen_bao_toan_du_lieu.md',f'''
# Phân quyền và bảo toàn dữ liệu

## Bốn lớp kiểm tra

1. Flutter: validation biểu mẫu và ẩn/khóa nút cho trải nghiệm.
2. Controller/JWT: xác định đúng người dùng, vai trò và quyền sở hữu; API không lấy memberId chủ thể từ body client.
3. Repository và SurveyRules: trạng thái, chỉ tiêu, câu hỏi/đáp án và transaction.
4. SQL Server: FK, UNIQUE, CHECK và khóa trong transaction.

Không lớp nào thay thế toàn bộ các lớp khác. Một client khác vẫn gọi thẳng API được nên chỉ ẩn nút là chưa đủ.

## Các quyền khác nhau

![Nhóm chức năng theo vai trò](phu_luc/04_nhom_chuc_nang_theo_vai_tro.png)

- Admin quản trị thành viên, danh mục, mẫu và trạng thái chiến dịch.
- Member có kế hoạch/chiến dịch riêng; người khác chỉ đọc được chi tiết chiến dịch khi đang Active theo API.
- Xem kết quả: owner hoặc Admin. `canManage` trong Details phục vụ quyền này, không có nghĩa Member được đổi status.
- Nháp: đọc theo member_id hiện tại. Khôi phục hồ sơ offline không cho vượt JWT/role ở server.

Đọc {b('Api/Controllers/CampaignController.cs','public async Task<IActionResult> Details')} và {b('Api/Controllers/CampaignController.cs','public async Task<IActionResult> Results')} để thấy kiểm tra quyền khác nhau.

## Khóa phiên và mật khẩu

JWT chứa version so với Members.TokenVersion. Đổi mật khẩu, logout hoặc Admin cập nhật tài khoản làm tăng version. Middleware so sánh DB trên mỗi yêu cầu. Không có danh sách blacklist từng token; cách này thu hồi theo toàn tài khoản.

Đăng xuất offline chưa gọi được server nên chỉ xóa phiên và nháp cục bộ; app có thông báo chưa thu hồi các phiên khác. Đổi mật khẩu thành công cũng xóa nháp cục bộ trong ChangePasswordPage. Cần biết hành vi này để tránh thử với nháp đang cần giữ.

## Khóa ngoại và xóa dữ liệu

Danh mục có mẫu: FK chặn xóa. Mẫu đã dùng: repository chủ động kiểm tra CampaignItems và FK vẫn bảo vệ quan hệ. Thành viên có dữ liệu liên quan: API trả xung đột; khóa thay vì xóa. Không có chức năng xóa chiến dịch trong UI/API hiện tại.

## Transaction và yêu cầu đồng thời

Checkout dùng Serializable và UPDLOCK/HOLDLOCK cho vùng cần giữ ổn định. Submit giữ khóa bản ghi Campaigns, vì vậy các lần gửi vào cùng chiến dịch không tự do cùng lúc vượt qua count/target rồi cùng INSERT. Cách này ưu tiên tính đúng cho đồ án nhỏ, không nên khẳng định đã tối ưu cho hệ thống tải lớn.

Idempotency nghĩa là thử lại cùng yêu cầu hợp lệ không tạo tác dụng phụ trùng. RequestId của checkout được sinh khi PlanPage mở và lưu trong bộ nhớ trang; SubmissionId được giữ trong payload nháp SQLite nên sống qua việc đóng/mở app. UNIQUE trong DB là bảo vệ cuối, không chỉ kiểm tra tồn tại bằng SELECT thông thường.

## Upload ảnh

ImageService kiểm tra 8 byte đầu định dạng PNG hoặc dấu đầu JPEG và dung lượng; đây là kiểm tra chữ ký tệp cơ bản, không phải hệ thống quét malware hay giải mã xác minh toàn bộ ảnh. Server sinh tên GUID để không dùng tên file gốc làm đường dẫn. RequestSizeLimit 6000000 lớn hơn giới hạn file 5 MiB để chứa phần multipart.

File ảnh nằm ngoài transaction SQL Server. Code dọn file mới khi ghi lỗi và xóa file cũ sau khi ghi DB thành công; không tuyên bố file và SQL nằm trong một distributed transaction. Sự cố tiến trình/hệ thống file vẫn là giới hạn vận hành.

## Bảo vệ thực tế còn giới hạn

Mạng Wi-Fi nội bộ đang dùng HTTP nên dữ liệu đường truyền không được TLS mã hóa. HTTPS là yêu cầu khi đưa qua Internet. Ảnh upload được phục vụ qua UseStaticFiles, đường dẫn ảnh không có phân quyền riêng theo chủ sở hữu. SQLite nháp chưa được mã hóa database riêng. Không có MFA, rate limiting theo tài khoản hoặc refresh-token flow được triển khai trong code.
''')

put('09_giai_trinh_yeu_cau_va_nghiep_vu.md','''
# Giải trình yêu cầu và nghiệp vụ

## Nhóm đáp ứng trực tiếp

Flutter Dart, SQLite trên điện thoại, REST API C# .NET 10 và SQL Server là công nghệ bắt buộc đã dùng. Đăng ký, đăng nhập, đổi mật khẩu, thành viên, gán Admin/Member, logout và phân quyền được thực hiện trực tiếp. Không nói quản lý role có tạo/xóa role tùy ý: hiện chỉ gán hai vai trò cố định.

## Nhóm chuyển đổi nghiệp vụ

| Trong yêu cầu | Trong app | Điểm giống về chức năng |
| --- | --- | --- |
| Sản phẩm | Mẫu khảo sát | CRUD, ảnh, phân loại, chi tiết và phân trang |
| Danh mục sản phẩm | Danh mục khảo sát | CRUD, ảnh và chặn xóa khi có mẫu |
| Giỏ hàng | Kế hoạch khảo sát | Chọn mẫu, sửa chỉ tiêu, bỏ mẫu và badge |
| Số lượng | Số phản hồi mục tiêu | Giá trị cập nhật theo mỗi mẫu |
| Checkout | Xác nhận tạo chiến dịch | Tạo đầu mục/chi tiết và xóa kế hoạch trong transaction |
| Đơn hàng | Chiến dịch | Chủ sở hữu, chi tiết, trạng thái, tìm kiếm/lọc ngày |
| Sản phẩm liên quan | Mẫu cùng danh mục | Liên quan theo danh mục, có phân trang |

Điều quan trọng là doanh nghiệp cần chọn một hoặc nhiều mẫu và chỉ tiêu trước mỗi đợt khảo sát. Không có giá, tổng tiền hoặc thu tiền trong kế hoạch. Giảng viên cần xem xét công nhận tương đương; không tự quy đổi thành điểm cuối cùng.

## Các chức năng riêng của đề tài

1. Câu hỏi text/single/multiple/rating; có bắt buộc/tùy chọn.
2. Người dùng tham gia và gửi phản hồi.
3. Kiểm tra đáp án theo kiểu, giới hạn và lựa chọn của mẫu.
4. Một tài khoản trả lời một lần cho mỗi mẫu trong một chiến dịch; giới hạn chỉ tiêu.
5. Thống kê văn bản, lựa chọn và điểm đánh giá trung bình.
6. Lưu nháp, mở lại offline và giữ mã gửi khi retry.
7. Chỉ chủ chiến dịch/Admin xem kết quả.

SQLite là yêu cầu công nghệ, còn cách dùng SQLite để lưu nháp là phần nghiệp vụ đề tài. Chống gửi trùng, transaction và cấu hình Wi-Fi là xử lý hỗ trợ kỹ thuật, không tự coi mỗi xử lý là một mục cộng điểm riêng.

## Điểm cộng đã làm và phần chưa làm

Đã làm: ảnh danh mục; kiểm tra mẫu có trong chiến dịch trước xóa; phân trang theo danh mục và tìm kiếm; mẫu liên quan có phân trang; tìm chiến dịch cho Member/Admin và lọc ngày. Bảng chi tiết nằm ở phu_luc/yeu_cau_va_tien_do.md.

Chưa làm: xác thực email, quên mật khẩu, đăng nhập Google/Facebook/Zalo và thanh toán. Email/mạng xã hội cần dịch vụ và cấu hình ngoài. Thanh toán chưa phù hợp vì không có nghiệp vụ thu tiền; chỉ cân nhắc nếu bán gói khảo sát. Không cần xây nghiệp vụ mua bán chỉ để giải thích yêu cầu.

Tổng điểm nhóm trang chủ trong đề và tổng các dòng bắt buộc có chênh lệch; giữ số đề và hỏi cách tính thay vì tự sửa. Không khẳng định chắc chắn đạt một mức điểm trước khi giảng viên xem phần tương đương.
''')

put('17_minh_hoa_du_lieu_cho_giang_vien.md',f'''
# Minh họa dữ liệu cho giảng viên

## Ví dụ đăng ký từ điện thoại

Tạo tài khoản trên app không có nghĩa tài khoản lưu trong SQLite điện thoại. Điện thoại nhập và gửi dữ liệu; API trên laptop kiểm tra và ghi vào SQL Server. Database hiện tại là BusinessSurvey, bảng Members; RoleId liên kết Roles và tài khoản đăng ký mới là Member.

```text
LoginPage ở chế độ đăng ký
    → MemberRepository.register → _post
    → HTTP POST /api/auth/register
    → AuthController.Register
    → MemberRepository.Add phía C#
    → INSERT vào BusinessSurvey.dbo.Members trên laptop
    → API trả kết quả để app báo đăng ký thành công
```

Mật khẩu được gửi tới API để xử lý rồi lưu dạng BCrypt hash trong PasswordHash; không lưu mật khẩu rõ. Luồng đăng ký không lưu tài khoản vào SQLite và chưa tự đăng nhập. Khi đăng nhập thành công sau đó, API mới cấp token, app lưu token/hồ sơ vào Secure Storage.

## Cách cho giảng viên xem bằng SQL Server Management Studio

1. Trên laptop, SQL Server và API đang chạy; điện thoại kết nối đúng máy chủ đó.
2. Mở SQL Server Management Studio (SSMS), kết nối server `.\\SQLEXPRESS` bằng Windows Authentication, chọn database BusinessSurvey.
3. Mở New Query. Đặt email mẫu của bạn trong biến @Email rồi chạy SELECT bên dưới trước khi đăng ký; email chưa tồn tại thì chưa có dòng.
4. Trên điện thoại đăng ký bằng đúng email đó và thông tin rõ nghĩa. Chờ app báo thành công.
5. Chạy lại đúng SELECT. Dòng tài khoản xuất hiện với MemberId, FullName, Email và RoleName là Member. Đây là bằng chứng dữ liệu được ghi từ điện thoại qua API vào database trên laptop.
6. Đăng nhập tài khoản mới trên app; nếu cần đăng nhập cùng tài khoản trên điện thoại khác đang kết nối cùng API để chứng minh dữ liệu tập trung.

```sql
USE BusinessSurvey;
DECLARE @Email VARCHAR(254) = 'tai_khoan_mau@example.com';

SELECT m.MemberId, m.FullName, m.Email,
       r.RoleName, m.IsActive, m.CreatedAt
FROM dbo.Members AS m
JOIN dbo.Roles AS r ON r.RoleId = m.RoleId
WHERE m.Email = @Email;
```

Thay email ví dụ bằng email tài khoản thử bạn chủ động tạo. Truy vấn chỉ đọc, không sửa hoặc xóa dữ liệu. Không dùng SELECT * hoặc đưa PasswordHash/token vào màn hình minh chứng. CreatedAt lưu UTC nên có thể lệch 7 giờ so với giờ Việt Nam; đó không phải tài khoản lưu sai thời điểm.

Nếu giáo viên muốn xem bằng giao diện SSMS: Object Explorer → Databases → BusinessSurvey → Tables có dbo.Members và dbo.Roles. Dùng New Query với cột chọn rõ ràng dễ minh họa hơn Edit Top Rows vì không vô tình sửa dữ liệu. Khi bạn đã chạy lại SELECT thì thấy dữ liệu mới; không phải chờ đồng bộ định kỳ.

## Mở code nào để giải thích ngay

| Bước | File và hàm |
| --- | --- |
| Nút đăng ký | {a('pages/login_page.dart','Future<void> _submit')} |
| Gửi HTTP | {a('repositories/member_repository.dart','static Future<void> register')} và `_post` trong cùng file |
| Endpoint server | {b('Api/Controllers/AuthController.cs','public async Task<IActionResult> Register')} |
| INSERT và BCrypt | {b('Api/Models/MemberRepository.cs','public Task<int> Add')} |
| Cấu trúc bảng Members | {b('Database/001_initial.sql',"CREATE TABLE Members")} |

## Câu giải thích có thể nói

“Em đăng ký trên điện thoại nhưng dữ liệu tài khoản lưu tập trung trong SQL Server trên laptop. Flutter gọi endpoint đăng ký, C# kiểm tra rồi INSERT bảng Members; mật khẩu được băm BCrypt. Em chạy lại SELECT theo email để thấy dòng mới và vai trò Member. SQLite chỉ dùng để lưu nháp trả lời, không phải nơi lưu tài khoản của hệ thống.”

## Các ví dụ tương tự

| Thao tác trên app | Dữ liệu được lưu hoặc đọc ở đâu | Cách minh họa |
| --- | --- | --- |
| Đăng nhập | Đọc Members/Roles trên SQL Server; ghi token và hồ sơ vào Secure Storage | Đăng nhập đúng/sai; mở AuthController.Login và SessionHelper.save |
| Admin thay role hoặc khóa | Members.RoleId, IsActive, TokenVersion | SELECT email trước/sau; request với token cũ bị từ chối |
| Tạo danh mục có ảnh | Categories.ImagePath và file wwwroot/uploads | Xem danh mục trên app, đường dẫn trong SQL, file ảnh trên laptop |
| Tạo mẫu và câu hỏi | Surveys và QuestionsJson | Xem mẫu/câu hỏi trên app rồi đối chiếu SurveyRepository.Add |
| Thêm vào kế hoạch | PlanItems theo MemberId/SurveyId | SELECT kế hoạch của tài khoản; badge đếm số mẫu |
| Xác nhận tạo chiến dịch | Campaigns/CampaignItems; PlanItems được làm trống | Xem chi tiết và SELECT trước/sau theo tài khoản |
| Chỉ lưu nháp | response_drafts SQLite trên chính điện thoại | Lưu nháp, ngắt kết nối, đóng/mở app và mở lại nháp |
| Gửi phản hồi thành công | Responses SQL Server; nháp tương ứng trên điện thoại bị xóa | Xem số phản hồi/kết quả và SELECT dòng Response |
| Thay địa chỉ máy chủ | Secure Storage khóa server_url trên điện thoại | Thoát/mở app và kiểm tra địa chỉ còn giữ |

Script `phu_luc/truy_van_minh_hoa_chi_doc.sql` có sẵn các SELECT tài khoản, kế hoạch, chiến dịch và phản hồi theo email. Nó không tự đăng ký, đổi role hoặc xóa dữ liệu. Chỉ các thao tác bạn thực hiện trong app mới làm phát sinh thay đổi cần minh họa.

## Làm sao chứng minh SQLite khi SSMS không nhìn thấy

SSMS kết nối SQL Server, không tự đọc SQLite trong vùng dữ liệu riêng của Android. Với bản release hiện tại, không nên hứa chỉ cần adb run-as là lấy được database vì release không debuggable.

Cách đơn giản là lưu một nháp có nội dung dễ nhận biết, làm mất kết nối máy chủ rồi mở lại nháp trong app. Mở LocalDatabase.saveDraft và ResponsePage._load/_store để chỉ rõ bảng và payload. Nếu giảng viên yêu cầu trực tiếp xem file .db bằng công cụ thì cần chuẩn bị riêng môi trường kiểm thử phù hợp; app hiện chưa có chức năng xuất database/nháp.

Các minh chứng kỹ thuật SQLite trên Android đã lưu trong DOAN/tai_nguyen_bao_cao/05_kiem_thu và 06_anh_minh_chung/kiem_thu_ky_thuat. Phân biệt minh chứng kiểm thử đã ghi với ảnh demo chức năng mới bạn chụp.

## Khi đổi điện thoại hoặc laptop

Điện thoại mới kết nối cùng API/database và đăng nhập thì đọc dữ liệu tập trung theo quyền. Nháp, URL và phiên cục bộ không có cơ chế đồng bộ do app tự triển khai. APK chứa mã và tài nguyên ứng dụng, không chứa các tài khoản/chiến dịch/nháp đã phát sinh từ thiết bị cũ.

Laptop mới không tự có database/file ảnh từ laptop cũ. Cần chuẩn bị SQL Server, cấu hình API và chuyển dữ liệu/ảnh bằng kế hoạch sao lưu phù hợp nếu muốn giữ dữ liệu. Các script schema trong bộ tài nguyên chỉ tạo cấu trúc, không thay thế backup dữ liệu thực tế.

SSMS có thể đóng sau khi kiểm tra; dịch vụ SQL Server và API vẫn phải chạy để app làm việc online. Tắt API/laptop không tự xóa dữ liệu, chỉ khiến điện thoại không truy cập được dữ liệu tập trung lúc đó.
''')

put('phu_luc/truy_van_minh_hoa_chi_doc.sql','''
-- Truy vấn CHỈ ĐỌC để minh họa bằng SSMS, không tự tạo/sửa/xóa dữ liệu.
-- Thay email mẫu bằng tài khoản thử mà bạn chủ động đăng ký trong app.
-- Không SELECT PasswordHash hoặc token.
USE BusinessSurvey;
DECLARE @Email VARCHAR(254) = 'tai_khoan_mau@example.com';

-- 1. Tài khoản đã đăng ký trên điện thoại.
SELECT m.MemberId, m.FullName, m.Email, r.RoleName, m.IsActive, m.CreatedAt
FROM dbo.Members AS m
JOIN dbo.Roles AS r ON r.RoleId=m.RoleId
WHERE m.Email=@Email;

-- 2. Kế hoạch của tài khoản trước khi tạo chiến dịch.
SELECT p.MemberId, p.SurveyId, s.Title, p.TargetCount
FROM dbo.PlanItems AS p
JOIN dbo.Members AS m ON m.MemberId=p.MemberId
JOIN dbo.Surveys AS s ON s.SurveyId=p.SurveyId
WHERE m.Email=@Email;

-- 3. Chiến dịch và từng mẫu do tài khoản sở hữu.
SELECT c.CampaignId, c.Title AS CampaignTitle, c.Status, c.CreatedAt,
       i.ItemId, s.Title AS SurveyTitle, i.TargetCount
FROM dbo.Campaigns AS c
JOIN dbo.Members AS m ON m.MemberId=c.MemberId
JOIN dbo.CampaignItems AS i ON i.CampaignId=c.CampaignId
JOIN dbo.Surveys AS s ON s.SurveyId=i.SurveyId
WHERE m.Email=@Email
ORDER BY c.CampaignId DESC, i.ItemId;

-- 4. Các phản hồi chính tài khoản đã gửi, không hiển thị nội dung trả lời riêng tư.
SELECT r.ResponseId, r.ItemId, i.CampaignId, s.Title AS SurveyTitle, r.CreatedAt
FROM dbo.Responses AS r
JOIN dbo.Members AS m ON m.MemberId=r.MemberId
JOIN dbo.CampaignItems AS i ON i.ItemId=r.ItemId
JOIN dbo.Surveys AS s ON s.SurveyId=i.SurveyId
WHERE m.Email=@Email
ORDER BY r.ResponseId DESC;
''')

qa=[
('Ứng dụng giải quyết việc gì?','Quản lý mẫu, lập kế hoạch, triển khai chiến dịch, thu phản hồi và xem kết quả khảo sát doanh nghiệp.','01_tong_quan_va_thuat_ngu.md'),
('Màn hình đăng ký nằm ở đâu?','LoginPage trong login_page.dart; biến _register chuyển giữa đăng nhập và đăng ký, cùng hàm _submit.','02_ban_do_man_hinh.md'),
('Trang chủ có phải chứa toàn bộ danh sách không?','HomePage là khung và menu; SurveyListView là widget dựng danh sách, tìm kiếm, lọc và phân trang bên trong.','02_ban_do_man_hinh.md'),
('Trang thêm mẫu và sửa mẫu có tách file không?','Không. SurveyEditPage dùng widget.survey null để thêm, khác null để sửa. QuestionDialog cũng nằm trong file này.','02_ban_do_man_hinh.md'),
('Admin và Member khác nhau thế nào?','Admin quản trị thành viên, danh mục, mẫu và trạng thái. Member quản lý kế hoạch, chiến dịch riêng, tham gia và xem kết quả chiến dịch mình sở hữu.','08_phan_quyen_bao_toan_du_lieu.md'),
('Member có được mở chiến dịch mình tạo không?','Không. Mọi thao tác đổi trạng thái chỉ Admin. canManage true cho owner dùng để hiển thị xem kết quả, không phải quyền đổi status.','08_phan_quyen_bao_toan_du_lieu.md'),
('Tại sao phải kiểm tra quyền ở API khi đã ẩn nút?','Một client khác vẫn có thể gọi HTTP trực tiếp. API phải xác thực token, role và owner để bảo vệ dữ liệu.','08_phan_quyen_bao_toan_du_lieu.md'),
('Ai có quyền xem kết quả?','Chủ chiến dịch hoặc Admin. Người tham gia thông thường chỉ gửi phản hồi, không được đọc kết quả người khác.','05_luong_xu_ly_tung_chuc_nang.md'),
('JWT nằm ở đâu và chứa gì?','Server tạo JWT sau login, client lưu Secure Storage. Claims có id, role và version; token có chữ ký/thời hạn, không lưu mật khẩu và không tự mã hóa payload.','07_doan_code_can_giai_thich.md'),
('Token sống bao lâu?','AuthController.Login đặt hết hạn sau 8 giờ, middleware có clock skew 30 giây. Không có refresh token flow hiện tại.','04_hieu_api_csharp.md'),
('Đổi quyền hoặc khóa tài khoản có phải đợi hết token không?','Không. OnTokenValidated đọc IsActive, role và TokenVersion mới từ DB để từ chối token cũ ở request tiếp theo.','08_phan_quyen_bao_toan_du_lieu.md'),
('Mật khẩu lưu thế nào?','Hash bằng BCrypt. Đăng nhập dùng BCrypt.Verify; không lưu mật khẩu rõ và không có hàm giải mã hash thành mật khẩu.','07_doan_code_can_giai_thich.md'),
('App dùng thư viện quản lý trạng thái nào?','StatefulWidget, State và setState; FutureBuilder dùng khi khôi phục phiên. Không dùng Bloc/Provider/Riverpod.','03_hieu_ma_flutter.md'),
('async/await và mounted có tác dụng gì?','Chờ tác vụ bất đồng bộ và chỉ cập nhật giao diện/điều hướng nếu State còn gắn với widget. Chúng không tự làm cho thao tác database có transaction.','03_hieu_ma_flutter.md'),
('Vì sao tách Repository?','Để màn hình tập trung nhập/hiển thị, repository Dart tập trung request và ánh xạ JSON. Repository C# tập trung SQL; dễ lần theo chức năng và dùng lại.','03_hieu_ma_flutter.md'),
('Dapper có phải Entity Framework không?','Không. Dapper là mapper nhẹ; code viết SQL và tham số trực tiếp, không dùng DbContext hoặc migration EF.','04_hieu_api_csharp.md'),
('SiteProvider có phải Provider Flutter không?','Không. SiteProvider là lớp C# scoped giữ SqlConnection và cung cấp các repository phía API.','04_hieu_api_csharp.md'),
('Câu hỏi lưu ở bảng nào?','QuestionsJson của Surveys, không có bảng Questions riêng. Câu trả lời ở AnswersJson của Responses.','06_co_so_du_lieu_va_json.md'),
('Vì sao dùng JSON cho câu hỏi?','Mẫu có nhiều kiểu câu hỏi và danh sách lựa chọn; JSON đơn giản cho phạm vi đồ án. Đổi lại truy vấn thống kê riêng bằng SQL khó hơn, hiện API deserialize để xử lý.','06_co_so_du_lieu_va_json.md'),
('Bốn loại câu trả lời khác nhau thế nào?','text là chuỗi tối đa 2000 ký tự; single là một chuỗi lựa chọn; multiple là mảng lựa chọn không trùng; rating là số nguyên 1–5.','07_doan_code_can_giai_thich.md'),
('Mỗi mẫu có bao nhiêu câu hỏi?','API cho 1–50 câu, tiêu đề mỗi câu tối đa 500 ký tự; câu chọn có 2–20 lựa chọn khác nhau, tối đa 200 ký tự mỗi lựa chọn.','07_doan_code_can_giai_thich.md'),
('Ảnh được lưu trong SQL Server không?','File ảnh lưu wwwroot/uploads; SQL Server lưu ImagePath. Flutter tải ảnh bằng URL.','06_co_so_du_lieu_va_json.md'),
('Thay ảnh mà lưu lỗi có làm mất ảnh cũ không?','Luồng hiện tại giữ ảnh cũ đến khi DB lưu thành công; ảnh mới khi ghi lỗi được finally dọn. File và SQL không nằm trong cùng transaction phân tán.','08_phan_quyen_bao_toan_du_lieu.md'),
('Tại sao mẫu có chiến dịch bị khóa sửa?','Để câu trả lời lịch sử vẫn mang ý nghĩa theo bộ câu hỏi đã triển khai; kể cả chiến dịch đã đóng/hủy vẫn bị khóa. Tạo mẫu mới nếu muốn đổi nội dung.','09_giai_trinh_yeu_cau_va_nghiep_vu.md'),
('Tại sao xóa danh mục bị lỗi?','Danh mục còn mẫu thì FK không cho xóa; controller trả 409 và giữ ảnh, dữ liệu hiện có.','08_phan_quyen_bao_toan_du_lieu.md'),
('Số trên badge kế hoạch nghĩa là gì?','Số mẫu khác nhau trong kế hoạch, không phải tổng số phản hồi mục tiêu. HomePage lấy plan.length.','05_luong_xu_ly_tung_chuc_nang.md'),
('Một mẫu được thêm hai lần vào kế hoạch không?','Không có hai dòng trùng MemberId+SurveyId. SQL dùng khóa ghép và PutPlan cập nhật số mục tiêu nếu đã tồn tại.','06_co_so_du_lieu_va_json.md'),
('Vì sao tạo chiến dịch cần transaction?','INSERT chiến dịch, INSERT chi tiết và DELETE kế hoạch phải cùng thành công; nếu lỗi rollback để không có dữ liệu dở dang hoặc mất kế hoạch.','07_doan_code_can_giai_thich.md'),
('Chống tạo chiến dịch hai lần thế nào?','RequestId theo tài khoản, tìm bản đã tạo trước rồi trả mã cũ; UNIQUE và transaction bảo vệ request đồng thời. RequestId hiện giữ trong PlanPage, không lưu nháp lâu dài.','08_phan_quyen_bao_toan_du_lieu.md'),
('Một người được gửi bao nhiêu lần?','Một lần trên ItemId. Cùng mẫu ở chiến dịch khác có ItemId khác nên có thể tham gia lại; retry cùng SubmissionId không tạo phản hồi mới.','05_luong_xu_ly_tung_chuc_nang.md'),
('Gửi thành công trên server nhưng điện thoại báo lỗi thì sao?','Nháp giữ SubmissionId, lần gửi lại cùng mã trả thành công mà không chèn thêm. Khi client nhận thành công thì xóa nháp.','07_doan_code_can_giai_thich.md'),
('Hai người cùng gửi lúc còn một chỉ tiêu thì sao?','Submit giữ khóa chiến dịch trong transaction, kiểm tra count và insert nối tiếp trong vùng khóa; người sau thấy đủ mục tiêu và bị chặn.','08_phan_quyen_bao_toan_du_lieu.md'),
('SQLite dùng vào đâu?','Lưu nháp trả lời cục bộ, không thay SQL Server cho nghiệp vụ online. Token không nằm trong SQLite.','06_co_so_du_lieu_va_json.md'),
('Vì sao có hai bảng draft?','survey_drafts là bảng cũ giữ để tương thích; response_drafts là bảng hiện tại với khóa member_id+item_id để phân biệt mỗi đợt triển khai.','06_co_so_du_lieu_va_json.md'),
('Mất mạng có đăng nhập mới hoặc xem mọi khảo sát không?','Không. Chỉ khôi phục hồ sơ và làm việc với nháp đã lưu. Không có full offline cache hay tự đồng bộ nền.','14_gioi_han_va_diem_de_nham.md'),
('Bấm gửi có lưu nháp trước không?','Có. ResponsePage._submit gọi _store trước API để nội dung còn nếu gửi lỗi. Chỉ nhập rồi rời trang mà chưa lưu/gửi không đảm bảo được giữ.','05_luong_xu_ly_tung_chuc_nang.md'),
('Đăng xuất khi không có mạng có thu hồi token mọi máy không?','Không đảm bảo. App xóa phiên/nháp cục bộ và báo chưa liên hệ server; token ở phiên khác chưa được tăng version qua API lúc đó.','08_phan_quyen_bao_toan_du_lieu.md'),
('Phân trang làm ở Flutter hay server?','API đếm và lấy trang bằng OFFSET/FETCH; Flutter gửi page và hiển thị PageButtons, không tải toàn bộ rồi cắt danh sách.','04_hieu_api_csharp.md'),
('Tìm mẫu liên quan dùng thuật toán gì?','Cùng CategoryId, khác SurveyId, mới nhất trước và có phân trang; không có AI hay chấm điểm tương đồng.','05_luong_xu_ly_tung_chuc_nang.md'),
('Tại sao lọc ngày Việt Nam nhưng SQL lưu UTC?','Ngày được đổi thành start/end UTC tại controller, dùng >= start và < đầu ngày kế tiếp để gồm toàn bộ ngày địa phương.','04_hieu_api_csharp.md'),
('Tỷ lệ câu chọn nhiều có thể hơn 100% không?','Có. Mỗi lựa chọn tính số lượt chọn chia tổng phản hồi; một người có thể chọn nhiều mục nên tổng tỷ lệ vượt 100% là hợp lý.','05_luong_xu_ly_tung_chuc_nang.md'),
('App có chạy khi rút USB không?','Có, release mở từ icon và dùng Wi-Fi. Máy tính vẫn phải bật API/SQL Server; địa chỉ Wi-Fi đổi thì sửa trong Kết nối máy chủ.','12_chay_he_thong_va_tim_loi.md'),
('App đã hỗ trợ mọi nền tảng chưa?','Flutter có khả năng đa nền tảng nhưng hiện chỉ kiểm chứng Android; SQLite hiện chưa được cấu hình cho web/Windows trong app này.','14_gioi_han_va_diem_de_nham.md'),
('Có cần thanh toán không?','Phạm vi hiện không bán gói hoặc thu tiền. Không thêm thanh toán khi chưa có nghiệp vụ; giải trình phần chuyển đổi giỏ hàng/chiến dịch riêng với giảng viên.','09_giai_trinh_yeu_cau_va_nghiep_vu.md'),
('Đã tự kiểm thử những gì?','134 lượt API, 10 kiểm thử Flutter, 6 kiểm tra SQLite trên Android ở đợt kỹ thuật trước; không cộng lẫn thành một số ca mới. Người dùng xác nhận Wi-Fi ổn.','12_chay_he_thong_va_tim_loi.md'),
('Có hạn chế nào cần thừa nhận?','Chưa email, quên mật khẩu, social login, thanh toán, full offline, export báo cáo, HTTPS triển khai Internet hoặc tối ưu tải lớn. Đây là bản nội bộ Android.','14_gioi_han_va_diem_de_nham.md'),
 ('Tạo tài khoản trên điện thoại thì lưu ở đâu?','API ghi vào BusinessSurvey.dbo.Members trên laptop; RoleId nối Roles, mật khẩu là BCrypt hash. Luồng đăng ký không tạo tài khoản trong SQLite.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Show dữ liệu tài khoản cho giáo viên thế nào?','SSMS kết nối .\\SQLEXPRESS, mở New Query trong BusinessSurvey; SELECT cột công khai theo email trước và sau khi đăng ký. Chạy lại SELECT để thấy dòng mới; không dùng SELECT * hoặc hiển thị PasswordHash.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Vì sao không xem SQLite điện thoại bằng SSMS?','Đó là hai database ở hai thiết bị khác nhau. SSMS dùng cho SQL Server; SQLite nằm trong vùng dữ liệu ứng dụng Android. Minh họa nháp bằng app offline và code LocalDatabase; app chưa có chức năng export .db.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Có cần mở SSMS suốt lúc app chạy không?','Không. Chỉ cần dịch vụ SQL Server và API chạy. SSMS là công cụ quản trị/quan sát; đóng cửa sổ SSMS không xóa hoặc dừng dịch vụ database.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Đóng API hoặc tắt laptop thì tài khoản đã tạo có mất không?','Không tự mất. Dữ liệu đã ghi vẫn ở SQL Server, nhưng điện thoại không gọi được API/database cho tới khi hệ thống chạy trở lại. Nháp cục bộ vẫn dùng được theo phạm vi đã lưu.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Build APK cho điện thoại khác có kèm dữ liệu cũ không?','Không. APK không đóng gói dữ liệu phát sinh. Máy mới kết nối cùng API/database và đăng nhập để đọc dữ liệu tập trung; nháp và cấu hình cục bộ không có cơ chế tự chuyển trong app.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Mang code sang laptop khác là có đầy đủ dữ liệu không?','Không. Code và script schema không thay backup dữ liệu SQL Server/ảnh. Cần cấu hình máy chủ mới và chuyển dữ liệu, file ảnh nếu muốn giữ nội dung đang có.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
 ('Làm sao phân biệt lưu nháp với gửi thành công?','Lưu nháp chỉ ghi SQLite; gửi thành công được API ghi Responses trong SQL Server rồi client xóa nháp tương ứng. Có thể đối chiếu số phản hồi trên app và SELECT dòng Response.','17_minh_hoa_du_lieu_cho_giang_vien.md'),
]
lines=['# Câu hỏi giảng viên và cách trả lời','','Các câu dưới là câu trả lời mẫu để hiểu và tự nói lại. Khi giáo viên hỏi code, mở đúng file/hàm ở tài liệu liên quan thay vì chỉ đọc thuộc câu trả lời.']
for i,(q,answer,target) in enumerate(qa,1): lines += ['',f'## Câu {i}  {q}',answer,'',f'Đọc thêm: [{target}]({target}).']
put('10_cau_hoi_giang_vien_va_cach_tra_loi.md','\n'.join(lines))

put('11_lo_trinh_on_va_tu_kiem_tra.md','''
# Lộ trình ôn và tự kiểm tra

## Vòng 1 Nắm nghiệp vụ

Đọc 01, 02 và 09. Tự giải thích sự khác nhau giữa mẫu, kế hoạch, chiến dịch, ItemId và phản hồi. Chỉ đúng nơi thêm mẫu, nơi duyệt mở và nơi trả lời. Giải thích được tại sao không có tiền thanh toán.

## Vòng 2 Lần theo code

Đọc 03–05. Mở app và code cạnh nhau. Chọn ba luồng: login, upload ảnh, gửi phản hồi. Với mỗi luồng phải nói được trang gọi hàm nào, URL nào, controller nào, repository nào và bảng nào.

## Vòng 3 Hiểu dữ liệu và tính đúng

Đọc 06–08. Tìm khóa UNIQUE, FK, CHECK và transaction trong code/script. Phân biệt validation client và server; phân biệt RequestId với SubmissionId; phân biệt xóa nháp và xóa phản hồi server.

## Vòng 4 Ôn câu hỏi và giới hạn

Đọc 10 và 14. Tự trả lời bằng lời của mình, ghi lại câu nào chưa hiểu. Không cần diễn tập demo đầy đủ nếu không muốn; có thể mở từng file theo câu hỏi để kiểm tra khả năng giải thích.

## Danh sách tự kiểm tra

- [ ] Giới thiệu đề tài trong khoảng một phút mà không dùng từ sản phẩm/đơn hàng sai nghiệp vụ.
- [ ] Tìm được LoginPage, SurveyEditPage, ResponsePage và ResultsPage trong code.
- [ ] Biết QuestionDialog, dialog danh mục và dialog mục tiêu nằm cùng file trang cha.
- [ ] Phân biệt repository Dart với repository C# và biết SiteProvider làm gì.
- [ ] Giải thích được từ nút Gửi tới bảng Responses và xóa nháp.
- [ ] Chỉ được chỗ API chặn Member gọi thao tác Admin.
- [ ] Chỉ được chỗ kiểm tra chủ chiến dịch xem kết quả.
- [ ] Chỉ được chỗ lưu ảnh mới và xóa ảnh cũ khi thành công.
- [ ] Giải thích vì sao mẫu đã nằm trong chiến dịch bị khóa sửa.
- [ ] Giải thích ba loại lưu trữ và vị trí file ảnh.
- [ ] Hiểu vì sao cùng SubmissionId thử lại không tạo thêm phản hồi.
- [ ] Hiểu phạm vi offline và tác động đăng xuất/đổi mật khẩu lên nháp.
- [ ] Phân biệt kết quả test tự động, test kỹ thuật Android và xác nhận thực tế của người dùng.
- [ ] Nói rõ chức năng nào tương đương và phần nào riêng cho khảo sát.
- [ ] Biết những phần chưa làm; không hứa app đã hỗ trợ iOS/web/Internet mọi nơi.

Nếu còn ít thời gian, ưu tiên 02 → 05 → 07 → 09 → 10 → 15. Với câu không nhớ số dòng, dùng Ctrl+F tên phương thức. Không sửa/xóa dữ liệu thật chỉ để tạo một tình huống cho phần ôn.
''')

put('12_chay_he_thong_va_tim_loi.md',f'''
# Chạy hệ thống, kiểm thử và tìm lỗi

## Chạy bình thường

```powershell
cd E:\\Zhoc\\LTDNT\\DOAN\\cuoiki\\SurveyApi
dotnet run
```

API dùng SQL Server đã chuẩn bị script và nghe cổng 5080. LaunchSettings Development lắng nghe 0.0.0.0 để truy cập cả localhost và mạng nội bộ. Kết nối máy chủ trong app nhập URL gốc, ví dụ http://192.168.1.7:5080, không thêm /api. IP là ví dụ hiện tại, có thể thay đổi theo router/mạng.

```powershell
cd E:\\Zhoc\\LTDNT\\DOAN\\cuoiki\\survey_app
flutter run
```

Đây là lệnh phát triển. Bản release đã cài mở trực tiếp từ icon, không cần terminal Flutter. Rút dây vẫn dùng online nếu điện thoại/máy tính cùng mạng và API/SQL Server chạy. Máy chủ tắt thì chỉ làm việc với nháp đã lưu.

Để cho phép Wi-Fi lần đầu nếu Windows chặn, chạy enable-wifi.ps1 bằng PowerShell Administrator. Script mở riêng TCP 5080 cho LocalSubnet, không tắt firewall. Đọc cấu hình tại {b('Properties/launchSettings.json')} và {ref('cuoiki/enable-wifi.ps1')}.

## Khi muốn build hoặc kiểm tra code

```powershell
flutter analyze
flutter test
flutter build apk --release
```

Lệnh build trên mặc định URL phát triển localhost nếu không truyền API_URL; app vẫn ưu tiên server_url đã lưu. Muốn APK mới mặc định Wi-Fi thì truyền --dart-define=API_URL=http://<IPv4-máy-chủ>:5080. Bản release dùng chữ ký debug hiện tại cho cập nhật nội bộ; không phải cấu hình phát hành cửa hàng hoàn chỉnh.

## Các lỗi thường hỏi

| Hiện tượng | Kiểm tra ở đâu |
| --- | --- |
| Không kết nối máy chủ | API còn chạy, IPv4 đúng, cùng Wi-Fi, cổng 5080, firewall, router không cô lập thiết bị; thử /api/health |
| Health OK nhưng không tải được dữ liệu | Kiểm tra kết nối SQL Server và log API; health chỉ báo web API phản hồi |
| 401 sau đổi quyền/mật khẩu | Token cũ bị thu hồi hoặc hết hạn; đăng nhập lại, không sửa app để bỏ xác thực |
| 403 | Không có vai trò hoặc quyền sở hữu cần thiết |
| Nút sửa mẫu bị mờ | Mẫu có IsUsed vì đã nằm trong CampaignItems; đây là ràng buộc lịch sử |
| Không thấy nút Trả lời | Chưa Active, đã trả lời hoặc đủ mục tiêu |
| Gửi lại nháp sau khi chiến dịch đóng bị chặn | Quy tắc server vẫn áp dụng cho nháp cũ; offline không giữ quyền gửi mãi |
| Chưa thấy ảnh mới | API phải là bản mới, URL hiện tại đúng; kiểm tra file/đường dẫn và lỗi upload |
| Không có mẫu liên quan | Danh mục chỉ có mẫu hiện tại hoặc chưa tải được phần liên quan |
| Lỗi database cột ImagePath | Máy mới chưa chạy 005_category_images.sql |

## Kết quả kiểm thử đã có

- API: 134 lượt kiểm tra đạt, có log trong bộ tài nguyên báo cáo. Script {ref('cuoiki/tests/full_api_check.ps1')} dùng API kiểm thử riêng cổng 5081 và tạo/dọn dữ liệu tạm.
- Flutter: 10 kiểm thử gồm SQLite, phân quyền giao diện, validation mật khẩu, mở đăng ký, layout ngang và cấu hình máy chủ; xem survey_app/test.
- Android SQLite đợt trước: 6 kiểm tra native, tách riêng với 10 kiểm thử Flutter.
- Bản release build/cài cập nhật thành công; người dùng xác nhận hoạt động qua Wi-Fi ổn. Không đồng nghĩa đã đo tải lớn hoặc test mọi tổ hợp thiết bị.

Không cần tự chạy lại toàn bộ test chỉ để ôn tài liệu. Nếu chạy integration_test lên điện thoại, không dùng luồng có thể gỡ cài đặt/xóa dữ liệu thật; ưu tiên đọc code hoặc thiết bị/dữ liệu thử riêng.
''')

put('14_gioi_han_va_diem_de_nham.md','''
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
''')

put('15_to_on_nhanh.md','''
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
''')

put('16_tu_dien_cu_phap_dart_csharp.md','''
# Từ điển cú pháp Dart và C# cần hiểu

## Dart trong app

| Cú pháp | Nghĩa và ví dụ đang dùng |
| --- | --- |
| class | Kiểu đối tượng, ví dụ Survey, LoginPage và ApiService |
| extends StatefulWidget | Widget có State giữ dữ liệu có thể thay đổi khi chạy |
| extends State<LoginPage> | State gắn với LoginPage; widget là cấu hình, State là giá trị đang thay đổi |
| StatelessWidget | Widget không giữ State thay đổi riêng, như CategoryImage hoặc PageButtons |
| final | Biến chỉ được gán một lần; object/list được tham chiếu vẫn có thể thay đổi nội dung |
| const | Giá trị/constructor hằng nếu điều kiện cho phép, khác với chỉ final |
| static | Thành viên thuộc lớp, gọi như ApiService.request mà không tạo ApiService() |
| _name hoặc _load | Dấu _ cho biết private trong phạm vi thư viện Dart, không phải biến bí mật hay dữ liệu được mã hóa |
| String? hoặc int? | Kiểu nullable, có thể nhận null |
| value! | Khẳng định không null tại điểm dùng; nếu thực tế null sẽ lỗi runtime, không phải kiểm tra an toàn tự động |
| object?.field | Chỉ truy cập khi object khác null, nếu null trả null |
| a ?? b | Dùng b khi a là null, ví dụ mô tả không có thì dùng chuỗi rỗng |
| a ??= b | Chỉ gán b nếu a hiện null; cũng có trong C# SiteProvider |
| ...items | Trải các phần tử danh sách vào danh sách widget |
| ...?items | Trải danh sách nếu khác null; ví dụ danh sách câu hỏi từ mẫu có thể chưa có |
| 'fromDate': ?fromDate | Null-aware map element trong Dart đang dùng; bỏ mục khi giá trị null |
| List<Survey> | Danh sách có kiểu phần tử Survey |
| Map<String, dynamic> | Map khóa chuỗi, giá trị có kiểu xác định lúc chạy; dùng khi đọc JSON |
| Future<T> | Kết quả T sẽ có sau tác vụ bất đồng bộ |
| async và await | Hàm bất đồng bộ và chờ Future; await không tự tạo transaction |
| => | Viết gọn hàm hoặc biểu thức trả về |
| as Map hoặc as int | Ép kiểu runtime; JSON sai cấu trúc có thể gây lỗi |
| fromMap/toMap | Tên quy ước của app để chuyển object và map, không phải phép biến đổi tự động của Dart |
| factory | Constructor có thể tạo/trả object theo cách riêng; ví dụ Question.fromMap |
| late | Khởi tạo giá trị muộn trước lần đọc đầu; không có nghĩa biến tự nhận null |
| setState(() {...}) | Đổi state và yêu cầu dựng lại UI |
| if (!mounted) return | Thoát nếu State đã không còn hoạt động sau await |
| try/catch/finally | Thử tác vụ, xử lý lỗi và luôn chạy phần dọn/đổi busy ở finally |
| Navigator.pop(context, result) | Đóng route và trả result cho nơi await push/showDialog |

Xem ví dụ cụ thể trong main.dart, models/survey.dart, SurveyListView và repository Dart. Không cần học cú pháp không xuất hiện trong dự án chỉ để giải trình.

## C# trong API

| Cú pháp | Nghĩa và ví dụ đang dùng |
| --- | --- |
| namespace | Nhóm tên để tổ chức lớp, ví dụ SurveyApi.Api.Models |
| class X(SiteProvider provider) | Primary constructor; ASP.NET Core DI cấp dependency khi tạo controller |
| public/private/protected | Phạm vi truy cập; protected connection dùng ở repository kế thừa |
| sealed | Không cho lớp khác kế thừa, như SiteProvider |
| abstract | Không tạo object trực tiếp từ lớp cơ sở, như BaseRepository |
| Task<T> và async/await | Tác vụ bất đồng bộ trả T, thường dùng cho DB hoặc file I/O |
| IActionResult | Controller có thể trả Ok, BadRequest, NotFound hoặc kết quả HTTP khác |
| [ApiController] | Bật các quy ước API, bao gồm xử lý validation model |
| [Route] và [HttpGet] | Ánh xạ URL và HTTP method tới action |
| [Authorize] | Yêu cầu xác thực; Roles="Admin" yêu cầu vai trò phù hợp |
| [FromForm] | Bind dữ liệu multipart/form-data; file ảnh là IFormFile |
| [Required], [Range], [MaxLength] | Ràng buộc validation trên model, khác ràng buộc SQL trong database |
| using var tx=... | Dispose khi kết thúc scope; transaction chưa commit sẽ không giữ thay đổi chưa commit |
| tx.Commit() | Xác nhận giao dịch thành công, không có nghĩa đã commit file ảnh cùng SQL |
| new { id, ... } | Object ẩn danh, thường dùng cho tham số Dapper hoặc JSON trả về |
| string? | Chuỗi có thể null theo nullable reference types |
| is null / is not null | Kiểm tra pattern null |
| is "single" or "multiple" | Pattern một trong hai loại câu hỏi |
| switch expression | Chọn biểu thức theo loại câu trả lời trong SurveyRules |
| record PageResult<T> | Kiểu chứa items/total/page/pageSize cho kết quả phân trang |
| Where/Select/Any/Count/Average | LINQ lọc, biến đổi, kiểm tra, đếm và tính trung bình |
| catch (...) when (...) | Chỉ bắt theo điều kiện, như lỗi SQL 2601/2627 hoặc FK 547 |
| JsonElement.ValueKind | Kiểu thực của giá trị JSON: String, Number, Array, Null... |
| Dispose/IDisposable | Giải phóng resource như connection hoặc transaction, không phải xóa bảng |

## SQL thường gặp

SELECT đọc; INSERT thêm; UPDATE sửa; DELETE xóa dòng. JOIN nối bảng theo khóa; WHERE lọc. PK định danh duy nhất; FK giữ quan hệ; UNIQUE chặn trùng; CHECK giới hạn giá trị. OFFSET/FETCH phân trang; OUTPUT INSERTED lấy mã vừa tạo. Tham số @id là giá trị được truyền riêng, không chép nội dung người dùng trực tiếp vào SQL.

Serializable, UPDLOCK và HOLDLOCK liên quan tới tính đúng khi nhiều yêu cầu thao tác cùng dữ liệu; không phải cơ chế xác thực người dùng. TokenVersion là quy tắc phiên của ứng dụng; không phải version schema SQLite hoặc version APK.
''')

# Toàn bộ file nguồn chính được lập mục lục; không đưa secret/config chứa giá trị riêng.
paths = sorted(set(
    [p.relative_to(DOAN).as_posix() for p in (DOAN/'cuoiki/survey_app/lib').rglob('*.dart')]
    + [p.relative_to(DOAN).as_posix() for p in (DOAN/'cuoiki/SurveyApi/Api').rglob('*.cs')]
    + [p.relative_to(DOAN).as_posix() for p in (DOAN/'cuoiki/SurveyApi/Services').rglob('*.cs')]
    + [API+'Program.cs']
))
lines=['# Mục lục toàn bộ file và hàm chính','','Đây là mục lục khai báo tự lấy theo code hiện tại. Tên lớp State có dấu _ là private trong thư viện Dart; phương thức cùng tên ở các lớp khác nhau không phải một hàm duy nhất. Các callback ẩn danh nằm trong build hoặc hàm cha, nên không phải lúc nào có tên riêng ở bảng.', '', '| File | Số dòng | Lớp và hàm khai báo |','| --- | --- | --- |']
snapshot=[]
for path in paths:
    text=read(path); symbols=[]
    for n,line in enumerate(text.splitlines(),1):
        m=re.search(r'\b(?:class|record)\s+(\w+)',line)
        if m: symbols.append((m.group(1),n,'lớp/model')); continue
        if path.endswith('.dart'):
            m=re.match(r'\s*(?:static\s+)?(?:Future<.+>|Future|void|Widget|String|bool|int|State<.+>|Map<.+>)\s+([\w]+)\s*\(',line)
        else:
            m=re.search(r'(?:^|\]\s*)\s*(?:public|private|protected|internal)\s+(?:(?:static|async|override|virtual)\s+)*[\w<>,?\[\]]+\s+(\w+)\s*\(',line)
        if m: symbols.append((m.group(1),n,'hàm'))
    cell='; '.join(f'`{name}` L{n}' for name,n,_ in symbols) or 'Cấu hình/khai báo đầu chương trình'
    lines.append(f'| {ref(path,label=path)} | {len(text.splitlines())} | {cell} |')
    snapshot.append({'file':path,'lines':len(text.splitlines()),'sha256':hashlib.sha256((DOAN/path).read_bytes()).hexdigest(),'symbols':[{'name':name,'line':n,'kind':kind} for name,n,kind in symbols]})
lines += ['', '## Tìm nhanh khi không nhớ file', '', 'Trong VS Code: Ctrl+P nhập tên file, Ctrl+G nhập số dòng, Ctrl+Shift+F tìm toàn workspace tên hàm/chuỗi thông báo. Nếu gặp hai CampaignRepository, chú ý đuôi .dart hoặc .cs. Chọn file trong cuoiki, tránh mở nhầm dự án trek_bikes_app hoặc WebApp tham khảo.']
lines += ['', '## Cấu hình Android và các file hỗ trợ', '', '| File | Vai trò |', '| --- | --- |']
for path,desc in [
 ('cuoiki/survey_app/pubspec.yaml','Tên/version package Dart, dependencies http, sqflite, Secure Storage, image_picker và test'),
 ('cuoiki/survey_app/android/app/src/main/AndroidManifest.xml','Tên hiển thị app, quyền Internet, icon và HTTP nội bộ'),
 ('cuoiki/survey_app/android/app/src/main/res/drawable/ic_survey_launcher.xml','Icon bảng khảo sát dạng vector XML, không phải ảnh upload của danh mục'),
 ('cuoiki/survey_app/android/app/src/main/kotlin/vn/edu/doan/survey_app/MainActivity.kt','Activity Android mở Flutter, không chứa nghiệp vụ khảo sát'),
 ('cuoiki/survey_app/android/app/build.gradle.kts','ApplicationId, version, cấu hình Android và ký bản release nội bộ'),
 ('cuoiki/survey_app/android/gradle.properties','Cấu hình Gradle/Kotlin phục vụ build'),
 (API+'SurveyApi.csproj','Target net10.0, package Dapper/JWT/SqlClient/BCrypt và adb reverse khi build Debug'),
 (API+'Properties/launchSettings.json','Cổng 5080, môi trường Development và địa chỉ lắng nghe'),
 ('cuoiki/enable-wifi.ps1','Quy tắc firewall cổng 5080 cho mạng nội bộ, chạy Administrator'),
 ('cuoiki/survey_app/test/widget_test.dart','Kiểm thử giao diện, quyền hiển thị, validation và layout'),
 ('cuoiki/survey_app/test/server_settings_test.dart','Kiểm thử URL, lưu cấu hình và form kết nối'),
 ('cuoiki/survey_app/test/local_database_test.dart','Kiểm thử nháp SQLite và nâng schema'),
 ('cuoiki/tests/full_api_check.ps1','Kiểm thử API với dữ liệu/tài khoản tạm và dọn sau khi chạy'),
]: lines.append(f'| {ref(path)} | {desc} |')
for name in ['001_initial.sql','002_member_management.sql','003_first_admin.sql','004_surveys_campaigns.sql','005_category_images.sql']:
    lines.append(f'| {ref(API+"Database/"+name)} | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |')
lines += ['', 'ConnectionStrings, Jwt Issuer/Audience và cấu hình môi trường nằm trong appsettings hoặc biến môi trường của API. Không sao chép giá trị bí mật/khóa local vào tài liệu ôn. APK release ở cuoiki/survey_app/build/app/outputs/flutter-apk/app-release.apk; đây là đầu ra build, không phải nguồn nghiệp vụ.']
put('13_muc_luc_file_va_ham.md','\n'.join(lines))
put('mau_nguon_da_doi_chieu.json',json.dumps({'updated':'2026-11-19','root':'DOAN','files':snapshot},ensure_ascii=False,indent=2))

appendix=OUT/'phu_luc'; appendix.mkdir(exist_ok=True)
resources=DOAN/'tai_nguyen_bao_cao'
for name in ['yeu_cau_va_tien_do.md','ma_tran_phan_quyen.md']:
    shutil.copy2(resources/'02_doi_chieu'/name,appendix/name)
shutil.copy2(resources/'07_huong_dan/danh_sach_api.md',appendix/'danh_sach_api.md')
shutil.copy2(resources/'04_co_so_du_lieu/tu_dien_du_lieu.md',appendix/'tu_dien_du_lieu.md')
database_folder=appendix/'schema_database';database_folder.mkdir(exist_ok=True)
shutil.copy2(resources/'04_co_so_du_lieu/sqlite_schema.sql',database_folder/'sqlite_schema.sql')
for source in (resources/'04_co_so_du_lieu/sql_server').glob('*.sql'):
    shutil.copy2(source,database_folder/source.name)
for file in (resources/'03_so_do').glob('*.png'): shutil.copy2(file,appendix/file.name)
put('phu_luc/README.md','''
# Sơ đồ và bảng đối chiếu

Ảnh PNG được sao chép từ bộ tài nguyên báo cáo và dùng để ôn kiến trúc, quan hệ SQL Server, luồng triển khai và nhóm quyền. Hình nhóm chức năng theo vai trò là sơ đồ mô tả, không phải sơ đồ UML use case đầy đủ. Bảng yêu cầu đã cập nhật ảnh danh mục hoàn thành.

- [Bảng đối chiếu](yeu_cau_va_tien_do.md).
- [Ma trận quyền](ma_tran_phan_quyen.md).
- [Danh sách endpoint REST API](danh_sach_api.md).
- [Từ điển dữ liệu](tu_dien_du_lieu.md).
- [Truy vấn minh họa chỉ đọc theo email](truy_van_minh_hoa_chi_doc.sql).
- schema_database chứa các script schema SQL Server và SQLite để đọc, không phải backup dữ liệu và không tự thực thi khi mở tài liệu.

Nguồn sơ đồ: DOAN/docs/draw_report_diagrams.py. Bộ tài nguyên báo cáo ở DOAN/tai_nguyen_bao_cao có thêm SQL scripts, log kiểm thử và kế hoạch ảnh minh chứng. Không sửa dữ liệu thật khi dùng các ví dụ để ôn.
''')

# Giữ một danh sách mốc tham chiếu để kiểm tra khi tài liệu sinh lại.
put('moc_tham_chieu_code.json',json.dumps([{'file':p,'needle':n,'line':ln} for p,n,ln in checked_refs],ensure_ascii=False,indent=2))
print(f'Study folder: {OUT}')
print(f'Screens/components: {len(screens)}; code files indexed: {len(paths)}; Q&A: {len(qa)}')
