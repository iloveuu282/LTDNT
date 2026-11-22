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
