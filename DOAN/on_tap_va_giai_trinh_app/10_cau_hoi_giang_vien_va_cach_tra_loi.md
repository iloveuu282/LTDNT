# Câu hỏi giảng viên và cách trả lời

Các câu dưới là câu trả lời mẫu để hiểu và tự nói lại. Khi giáo viên hỏi code, mở đúng file/hàm ở tài liệu liên quan thay vì chỉ đọc thuộc câu trả lời.

## Câu 1  Ứng dụng giải quyết việc gì?
Quản lý mẫu, lập kế hoạch, triển khai chiến dịch, thu phản hồi và xem kết quả khảo sát doanh nghiệp.

Đọc thêm: [01_tong_quan_va_thuat_ngu.md](01_tong_quan_va_thuat_ngu.md).

## Câu 2  Màn hình đăng ký nằm ở đâu?
LoginPage trong login_page.dart; biến _register chuyển giữa đăng nhập và đăng ký, cùng hàm _submit.

Đọc thêm: [02_ban_do_man_hinh.md](02_ban_do_man_hinh.md).

## Câu 3  Trang chủ có phải chứa toàn bộ danh sách không?
HomePage là khung và menu; SurveyListView là widget dựng danh sách, tìm kiếm, lọc và phân trang bên trong.

Đọc thêm: [02_ban_do_man_hinh.md](02_ban_do_man_hinh.md).

## Câu 4  Trang thêm mẫu và sửa mẫu có tách file không?
Không. SurveyEditPage dùng widget.survey null để thêm, khác null để sửa. QuestionDialog cũng nằm trong file này.

Đọc thêm: [02_ban_do_man_hinh.md](02_ban_do_man_hinh.md).

## Câu 5  Admin và Member khác nhau thế nào?
Admin quản trị thành viên, danh mục, mẫu và trạng thái. Member quản lý kế hoạch, chiến dịch riêng, tham gia và xem kết quả chiến dịch mình sở hữu.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 6  Member có được mở chiến dịch mình tạo không?
Không. Mọi thao tác đổi trạng thái chỉ Admin. canManage true cho owner dùng để hiển thị xem kết quả, không phải quyền đổi status.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 7  Tại sao phải kiểm tra quyền ở API khi đã ẩn nút?
Một client khác vẫn có thể gọi HTTP trực tiếp. API phải xác thực token, role và owner để bảo vệ dữ liệu.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 8  Ai có quyền xem kết quả?
Chủ chiến dịch hoặc Admin. Người tham gia thông thường chỉ gửi phản hồi, không được đọc kết quả người khác.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 9  JWT nằm ở đâu và chứa gì?
Server tạo JWT sau login, client lưu Secure Storage. Claims có id, role và version; token có chữ ký/thời hạn, không lưu mật khẩu và không tự mã hóa payload.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 10  Token sống bao lâu?
AuthController.Login đặt hết hạn sau 8 giờ, middleware có clock skew 30 giây. Không có refresh token flow hiện tại.

Đọc thêm: [04_hieu_api_csharp.md](04_hieu_api_csharp.md).

## Câu 11  Đổi quyền hoặc khóa tài khoản có phải đợi hết token không?
Không. OnTokenValidated đọc IsActive, role và TokenVersion mới từ DB để từ chối token cũ ở request tiếp theo.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 12  Mật khẩu lưu thế nào?
Hash bằng BCrypt. Đăng nhập dùng BCrypt.Verify; không lưu mật khẩu rõ và không có hàm giải mã hash thành mật khẩu.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 13  App dùng thư viện quản lý trạng thái nào?
StatefulWidget, State và setState; FutureBuilder dùng khi khôi phục phiên. Không dùng Bloc/Provider/Riverpod.

Đọc thêm: [03_hieu_ma_flutter.md](03_hieu_ma_flutter.md).

## Câu 14  async/await và mounted có tác dụng gì?
Chờ tác vụ bất đồng bộ và chỉ cập nhật giao diện/điều hướng nếu State còn gắn với widget. Chúng không tự làm cho thao tác database có transaction.

Đọc thêm: [03_hieu_ma_flutter.md](03_hieu_ma_flutter.md).

## Câu 15  Vì sao tách Repository?
Để màn hình tập trung nhập/hiển thị, repository Dart tập trung request và ánh xạ JSON. Repository C# tập trung SQL; dễ lần theo chức năng và dùng lại.

Đọc thêm: [03_hieu_ma_flutter.md](03_hieu_ma_flutter.md).

## Câu 16  Dapper có phải Entity Framework không?
Không. Dapper là mapper nhẹ; code viết SQL và tham số trực tiếp, không dùng DbContext hoặc migration EF.

Đọc thêm: [04_hieu_api_csharp.md](04_hieu_api_csharp.md).

## Câu 17  SiteProvider có phải Provider Flutter không?
Không. SiteProvider là lớp C# scoped giữ SqlConnection và cung cấp các repository phía API.

Đọc thêm: [04_hieu_api_csharp.md](04_hieu_api_csharp.md).

## Câu 18  Câu hỏi lưu ở bảng nào?
QuestionsJson của Surveys, không có bảng Questions riêng. Câu trả lời ở AnswersJson của Responses.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 19  Vì sao dùng JSON cho câu hỏi?
Mẫu có nhiều kiểu câu hỏi và danh sách lựa chọn; JSON đơn giản cho phạm vi đồ án. Đổi lại truy vấn thống kê riêng bằng SQL khó hơn, hiện API deserialize để xử lý.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 20  Bốn loại câu trả lời khác nhau thế nào?
text là chuỗi tối đa 2000 ký tự; single là một chuỗi lựa chọn; multiple là mảng lựa chọn không trùng; rating là số nguyên 1–5.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 21  Mỗi mẫu có bao nhiêu câu hỏi?
API cho 1–50 câu, tiêu đề mỗi câu tối đa 500 ký tự; câu chọn có 2–20 lựa chọn khác nhau, tối đa 200 ký tự mỗi lựa chọn.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 22  Ảnh được lưu trong SQL Server không?
File ảnh lưu wwwroot/uploads; SQL Server lưu ImagePath. Flutter tải ảnh bằng URL.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 23  Thay ảnh mà lưu lỗi có làm mất ảnh cũ không?
Luồng hiện tại giữ ảnh cũ đến khi DB lưu thành công; ảnh mới khi ghi lỗi được finally dọn. File và SQL không nằm trong cùng transaction phân tán.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 24  Tại sao mẫu có chiến dịch bị khóa sửa?
Để câu trả lời lịch sử vẫn mang ý nghĩa theo bộ câu hỏi đã triển khai; kể cả chiến dịch đã đóng/hủy vẫn bị khóa. Tạo mẫu mới nếu muốn đổi nội dung.

Đọc thêm: [09_giai_trinh_yeu_cau_va_nghiep_vu.md](09_giai_trinh_yeu_cau_va_nghiep_vu.md).

## Câu 25  Tại sao xóa danh mục bị lỗi?
Danh mục còn mẫu thì FK không cho xóa; controller trả 409 và giữ ảnh, dữ liệu hiện có.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 26  Số trên badge kế hoạch nghĩa là gì?
Số mẫu khác nhau trong kế hoạch, không phải tổng số phản hồi mục tiêu. HomePage lấy plan.length.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 27  Một mẫu được thêm hai lần vào kế hoạch không?
Không có hai dòng trùng MemberId+SurveyId. SQL dùng khóa ghép và PutPlan cập nhật số mục tiêu nếu đã tồn tại.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 28  Vì sao tạo chiến dịch cần transaction?
INSERT chiến dịch, INSERT chi tiết và DELETE kế hoạch phải cùng thành công; nếu lỗi rollback để không có dữ liệu dở dang hoặc mất kế hoạch.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 29  Chống tạo chiến dịch hai lần thế nào?
RequestId theo tài khoản, tìm bản đã tạo trước rồi trả mã cũ; UNIQUE và transaction bảo vệ request đồng thời. RequestId hiện giữ trong PlanPage, không lưu nháp lâu dài.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 30  Một người được gửi bao nhiêu lần?
Một lần trên ItemId. Cùng mẫu ở chiến dịch khác có ItemId khác nên có thể tham gia lại; retry cùng SubmissionId không tạo phản hồi mới.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 31  Gửi thành công trên server nhưng điện thoại báo lỗi thì sao?
Nháp giữ SubmissionId, lần gửi lại cùng mã trả thành công mà không chèn thêm. Khi client nhận thành công thì xóa nháp.

Đọc thêm: [07_doan_code_can_giai_thich.md](07_doan_code_can_giai_thich.md).

## Câu 32  Hai người cùng gửi lúc còn một chỉ tiêu thì sao?
Submit giữ khóa chiến dịch trong transaction, kiểm tra count và insert nối tiếp trong vùng khóa; người sau thấy đủ mục tiêu và bị chặn.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 33  SQLite dùng vào đâu?
Lưu nháp trả lời cục bộ, không thay SQL Server cho nghiệp vụ online. Token không nằm trong SQLite.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 34  Vì sao có hai bảng draft?
survey_drafts là bảng cũ giữ để tương thích; response_drafts là bảng hiện tại với khóa member_id+item_id để phân biệt mỗi đợt triển khai.

Đọc thêm: [06_co_so_du_lieu_va_json.md](06_co_so_du_lieu_va_json.md).

## Câu 35  Mất mạng có đăng nhập mới hoặc xem mọi khảo sát không?
Không. Chỉ khôi phục hồ sơ và làm việc với nháp đã lưu. Không có full offline cache hay tự đồng bộ nền.

Đọc thêm: [14_gioi_han_va_diem_de_nham.md](14_gioi_han_va_diem_de_nham.md).

## Câu 36  Bấm gửi có lưu nháp trước không?
Có. ResponsePage._submit gọi _store trước API để nội dung còn nếu gửi lỗi. Chỉ nhập rồi rời trang mà chưa lưu/gửi không đảm bảo được giữ.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 37  Đăng xuất khi không có mạng có thu hồi token mọi máy không?
Không đảm bảo. App xóa phiên/nháp cục bộ và báo chưa liên hệ server; token ở phiên khác chưa được tăng version qua API lúc đó.

Đọc thêm: [08_phan_quyen_bao_toan_du_lieu.md](08_phan_quyen_bao_toan_du_lieu.md).

## Câu 38  Phân trang làm ở Flutter hay server?
API đếm và lấy trang bằng OFFSET/FETCH; Flutter gửi page và hiển thị PageButtons, không tải toàn bộ rồi cắt danh sách.

Đọc thêm: [04_hieu_api_csharp.md](04_hieu_api_csharp.md).

## Câu 39  Tìm mẫu liên quan dùng thuật toán gì?
Cùng CategoryId, khác SurveyId, mới nhất trước và có phân trang; không có AI hay chấm điểm tương đồng.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 40  Tại sao lọc ngày Việt Nam nhưng SQL lưu UTC?
Ngày được đổi thành start/end UTC tại controller, dùng >= start và < đầu ngày kế tiếp để gồm toàn bộ ngày địa phương.

Đọc thêm: [04_hieu_api_csharp.md](04_hieu_api_csharp.md).

## Câu 41  Tỷ lệ câu chọn nhiều có thể hơn 100% không?
Có. Mỗi lựa chọn tính số lượt chọn chia tổng phản hồi; một người có thể chọn nhiều mục nên tổng tỷ lệ vượt 100% là hợp lý.

Đọc thêm: [05_luong_xu_ly_tung_chuc_nang.md](05_luong_xu_ly_tung_chuc_nang.md).

## Câu 42  App có chạy khi rút USB không?
Có, release mở từ icon và dùng Wi-Fi. Máy tính vẫn phải bật API/SQL Server; địa chỉ Wi-Fi đổi thì sửa trong Kết nối máy chủ.

Đọc thêm: [12_chay_he_thong_va_tim_loi.md](12_chay_he_thong_va_tim_loi.md).

## Câu 43  App đã hỗ trợ mọi nền tảng chưa?
Flutter có khả năng đa nền tảng nhưng hiện chỉ kiểm chứng Android; SQLite hiện chưa được cấu hình cho web/Windows trong app này.

Đọc thêm: [14_gioi_han_va_diem_de_nham.md](14_gioi_han_va_diem_de_nham.md).

## Câu 44  Có cần thanh toán không?
Phạm vi hiện không bán gói hoặc thu tiền. Không thêm thanh toán khi chưa có nghiệp vụ; giải trình phần chuyển đổi giỏ hàng/chiến dịch riêng với giảng viên.

Đọc thêm: [09_giai_trinh_yeu_cau_va_nghiep_vu.md](09_giai_trinh_yeu_cau_va_nghiep_vu.md).

## Câu 45  Đã tự kiểm thử những gì?
134 lượt API, 10 kiểm thử Flutter, 6 kiểm tra SQLite trên Android ở đợt kỹ thuật trước; không cộng lẫn thành một số ca mới. Người dùng xác nhận Wi-Fi ổn.

Đọc thêm: [12_chay_he_thong_va_tim_loi.md](12_chay_he_thong_va_tim_loi.md).

## Câu 46  Có hạn chế nào cần thừa nhận?
Chưa email, quên mật khẩu, social login, thanh toán, full offline, export báo cáo, HTTPS triển khai Internet hoặc tối ưu tải lớn. Đây là bản nội bộ Android.

Đọc thêm: [14_gioi_han_va_diem_de_nham.md](14_gioi_han_va_diem_de_nham.md).

## Câu 47  Tạo tài khoản trên điện thoại thì lưu ở đâu?
API ghi vào BusinessSurvey.dbo.Members trên laptop; RoleId nối Roles, mật khẩu là BCrypt hash. Luồng đăng ký không tạo tài khoản trong SQLite.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 48  Show dữ liệu tài khoản cho giáo viên thế nào?
SSMS kết nối .\SQLEXPRESS, mở New Query trong BusinessSurvey; SELECT cột công khai theo email trước và sau khi đăng ký. Chạy lại SELECT để thấy dòng mới; không dùng SELECT * hoặc hiển thị PasswordHash.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 49  Vì sao không xem SQLite điện thoại bằng SSMS?
Đó là hai database ở hai thiết bị khác nhau. SSMS dùng cho SQL Server; SQLite nằm trong vùng dữ liệu ứng dụng Android. Minh họa nháp bằng app offline và code LocalDatabase; app chưa có chức năng export .db.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 50  Có cần mở SSMS suốt lúc app chạy không?
Không. Chỉ cần dịch vụ SQL Server và API chạy. SSMS là công cụ quản trị/quan sát; đóng cửa sổ SSMS không xóa hoặc dừng dịch vụ database.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 51  Đóng API hoặc tắt laptop thì tài khoản đã tạo có mất không?
Không tự mất. Dữ liệu đã ghi vẫn ở SQL Server, nhưng điện thoại không gọi được API/database cho tới khi hệ thống chạy trở lại. Nháp cục bộ vẫn dùng được theo phạm vi đã lưu.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 52  Build APK cho điện thoại khác có kèm dữ liệu cũ không?
Không. APK không đóng gói dữ liệu phát sinh. Máy mới kết nối cùng API/database và đăng nhập để đọc dữ liệu tập trung; nháp và cấu hình cục bộ không có cơ chế tự chuyển trong app.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 53  Mang code sang laptop khác là có đầy đủ dữ liệu không?
Không. Code và script schema không thay backup dữ liệu SQL Server/ảnh. Cần cấu hình máy chủ mới và chuyển dữ liệu, file ảnh nếu muốn giữ nội dung đang có.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).

## Câu 54  Làm sao phân biệt lưu nháp với gửi thành công?
Lưu nháp chỉ ghi SQLite; gửi thành công được API ghi Responses trong SQL Server rồi client xóa nháp tương ứng. Có thể đối chiếu số phản hồi trên app và SELECT dòng Response.

Đọc thêm: [17_minh_hoa_du_lieu_cho_giang_vien.md](17_minh_hoa_du_lieu_cho_giang_vien.md).
