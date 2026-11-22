# Hiểu API C# và các lớp phía máy chủ

## Program và Dependency Injection

[Program.cs](<../cuoiki/SurveyApi/Program.cs>) — dòng 6: đọc cấu hình, đăng ký Controllers, SiteProvider, ImageService, xác thực JWT và authorization. API Development có khóa local bền vững nếu chưa cấu hình secret; Production yêu cầu secret riêng. Không mở hoặc trình chiếu giá trị khóa khi giải trình.

AddScoped tạo SiteProvider theo vòng đời request. [SiteProvider.cs](<../cuoiki/SurveyApi/Api/Models/SiteProvider.cs>) — dòng 5 giữ SqlConnection và khởi tạo lười các repository bằng ??=. Kết thúc scope sẽ Dispose connection. BaseRepository giữ IDbConnection để các repository dùng Dapper.

UseAuthentication xác định danh tính từ token; UseAuthorization kiểm tra quyền. OnTokenValidated đọc thành viên hiện tại để so IsActive, TokenVersion và role. UseStaticFiles phục vụ ảnh; UseExceptionHandler trả thông báo lỗi chung khi chưa xử lý tại controller. GET /api/health chỉ kiểm tra tiến trình trả lời, không chứng minh SQL Server hoặc mọi nghiệp vụ đều đang khỏe.

## Controller và repository khác nhau

Controller nhận HTTP, nhận model đầu vào, kiểm tra quyền/điều kiện, chọn HTTP status và gọi repository/service. Repository thực hiện SQL và transaction. Model C# mô tả request/response và validation attributes; không tự lưu dữ liệu chỉ vì đã tạo object.

| Controller | Repository/service gọi tiếp | Nghiệp vụ |
| --- | --- | --- |
| [AuthController.cs](<../cuoiki/SurveyApi/Api/Controllers/AuthController.cs>) — dòng 13 | MemberRepository | Register, Login, Me, ChangePassword, Logout |
| [MemberController.cs](<../cuoiki/SurveyApi/Api/Controllers/MemberController.cs>) — dòng 10 | MemberRepository | Get, Roles, Update, Delete; toàn controller chỉ Admin |
| [CategoryController.cs](<../cuoiki/SurveyApi/Api/Controllers/CategoryController.cs>) — dòng 10 | CategoryRepository và ImageService | Get, Add, Update, Delete; thêm/sửa multipart |
| [SurveyController.cs](<../cuoiki/SurveyApi/Api/Controllers/SurveyController.cs>) — dòng 10 | SurveyRepository, SurveyRules, ImageService | Get, Details, Related, Add, Update, Delete |
| [PlanController.cs](<../cuoiki/SurveyApi/Api/Controllers/PlanController.cs>) — dòng 10 | CampaignRepository | GetPlan, PutPlan, RemovePlan, Checkout |
| [CampaignController.cs](<../cuoiki/SurveyApi/Api/Controllers/CampaignController.cs>) — dòng 11 | CampaignRepository, SurveyRepository, SurveyRules gián tiếp | danh sách, chi tiết, trạng thái, phản hồi, kết quả |

## Model và quy tắc

[Member.cs](<../cuoiki/SurveyApi/Api/Models/Member.cs>) — dòng 5: Member, LoginModel, RegisterModel, ChangePasswordModel, UpdateMemberModel. RegisterModel kế thừa dữ liệu đăng nhập và thêm FullName. PublicMember trong AuthController không trả PasswordHash cho app.

[Survey.cs](<../cuoiki/SurveyApi/Api/Models/Survey.cs>) — dòng 6: Category, CategoryForm, Survey, Question, SurveyForm, PageResult, TargetModel, CheckoutModel, ResponseModel, StatusModel, PlanItem, Campaign và CampaignItem. Không có file riêng cho mỗi model.

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
