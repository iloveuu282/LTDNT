# Từ điển dữ liệu và quy tắc

## SQL Server

| Bảng | Khóa và trường chính | Vai trò |
| --- | --- | --- |
| Roles | RoleId PK, RoleName UNIQUE | Hai vai trò Admin và Member |
| Members | MemberId PK; FullName, Email UNIQUE, PasswordHash, RoleId FK, CreatedAt, IsActive, TokenVersion | Tài khoản và kiểm soát phiên |
| Categories | CategoryId PK; CategoryName UNIQUE, Description, ImagePath NULL | Phân loại và ảnh danh mục |
| Surveys | SurveyId PK; CategoryId FK, Title, Description, ImagePath, QuestionsJson, CreatedAt | Mẫu và nội dung câu hỏi |
| PlanItems | PK ghép MemberId + SurveyId; cả hai là FK; TargetCount | Kế hoạch riêng của thành viên |
| Campaigns | CampaignId PK; MemberId FK, Title, Status, RequestId, CreatedAt; UNIQUE MemberId + RequestId | Chiến dịch và mã chống tạo trùng |
| CampaignItems | ItemId PK; CampaignId FK, SurveyId FK, TargetCount; UNIQUE CampaignId + SurveyId | Mẫu và chỉ tiêu trong chiến dịch |
| Responses | ResponseId PK; ItemId FK, MemberId FK, SubmissionId UNIQUE, AnswersJson, CreatedAt; UNIQUE ItemId + MemberId | Phản hồi và mã chống gửi trùng |

QuestionsJson là danh sách câu hỏi gồm id, title, type, required và options. AnswersJson là đối tượng dùng mã câu hỏi làm khóa; giá trị phụ thuộc loại câu hỏi. Các ngày CreatedAt phía SQL Server lưu UTC; bộ lọc chiến dịch đổi ngày Việt Nam sang khoảng UTC.

Ảnh là file trên máy chủ trong wwwroot/uploads, SQL Server chỉ lưu đường dẫn. Không đưa nội dung file ảnh vào SQLite hoặc cột SQL Server. Danh mục còn mẫu không được xóa; mẫu đã có trong chiến dịch không sửa/xóa. Số mục tiêu nằm trong 1 đến 100000.

## SQLite trên điện thoại

| Bảng | Trường | Sử dụng |
| --- | --- | --- |
| response_drafts | member_id, item_id, campaign_id, payload_json, updated_at; PK member_id + item_id | Nháp trả lời hiện tại, tách tài khoản và chiến dịch qua item_id |
| survey_drafts | member_id, survey_id, answers_json, updated_at; PK member_id + survey_id | Bảng cũ còn giữ để tương thích database phiên bản trước |

payload_json chứa survey, answers và submissionId theo cách lưu thực tế trong ResponsePage. Không có FK xuyên hai database: id phía SQLite là tham chiếu nghiệp vụ, không phải ràng buộc SQL Server trên điện thoại. Khi gửi lại, API vẫn kiểm tra quyền và trạng thái hiện tại.

Token, hồ sơ phiên và server_url lưu bằng Flutter Secure Storage, không phải các bảng SQLite. Xem LocalDatabase và ResponsePage trong mã nguồn nếu cần trích đoạn minh họa.

Thứ tự chuẩn bị SQL Server: 001 → 002 → 004 → 005. File 003 chỉ cấp Admin thủ công cho email đã chọn; không tự chạy khi cài mới.
