# Kế hoạch thực hiện

## 1. Phạm vi đề xuất

Ứng dụng giúp doanh nghiệp chọn hoặc tạo mẫu khảo sát, lập kế hoạch triển khai, tạo chiến dịch, thu thập phản hồi và xem thống kê cơ bản.

- Admin: quản lý thành viên, vai trò, danh mục, mẫu khảo sát và trạng thái chiến dịch; xem thống kê.
- Member: xem/tìm mẫu, thêm vào kế hoạch, tạo và xem chiến dịch của mình, trả lời khảo sát đang mở.
- Bản đầu phục vụ một doanh nghiệp, chỉ có hai vai trò Admin và Member; không xây dựng quản lý nhiều doanh nghiệp hoặc lời mời nhân viên.
- Người dùng đã đăng nhập có thể trả lời chiến dịch đang mở. Khảo sát công khai không cần đăng nhập chưa thuộc bản đầu.
- Câu hỏi gồm văn bản, chọn một, chọn nhiều và thang điểm; có cờ bắt buộc và thứ tự.
- Thống kê gồm số phản hồi, tỷ lệ lựa chọn và điểm trung bình cho câu hỏi thang điểm.

Ưu tiên theo yêu cầu mới: đủ chức năng chấm điểm, nghiệp vụ khảo sát dễ hiểu, code mạch lạc và gần hai dự án mẫu. Không thêm tầng kiến trúc hoặc nghiệp vụ khi chưa cần.

## 2. Đối chiếu bảng yêu cầu

| Yêu cầu gốc | Phương án khảo sát | Phạm vi |
| --- | --- | --- |
| Đăng ký, đăng nhập, đổi mật khẩu, logout | Giữ nguyên | Bắt buộc |
| Quản lý member, role, phân quyền | Admin/Member; API kiểm tra vai trò và chủ sở hữu chiến dịch | Bắt buộc |
| Danh mục: xem, thêm, sửa, xóa | Danh mục khảo sát | Bắt buộc |
| Chặn xóa danh mục có sản phẩm | Chặn xóa danh mục chứa mẫu khảo sát | Bắt buộc |
| Sản phẩm theo danh mục | Mẫu khảo sát có ảnh, mô tả, câu hỏi | Tương đương, cần giảng viên chấp nhận |
| CRUD sản phẩm, upload ảnh, phân trang | CRUD mẫu; thêm ảnh, thay ảnh và dọn ảnh cũ, xóa ảnh khi xóa mẫu | Bắt buộc theo phương án tương đương |
| Trang chủ, mới nhất, danh mục, tìm kiếm, chi tiết | Danh sách mẫu, lọc, tìm, chi tiết; phân trang ở API | Bắt buộc theo phương án tương đương |
| Giỏ hàng và số lượng trên icon | Kế hoạch chứa mẫu đã chọn; badge đếm số mẫu khác nhau | Tương đương, cần giảng viên chấp nhận |
| Cập nhật số lượng, xóa khỏi giỏ | Sửa số phản hồi mục tiêu, bỏ mẫu khỏi kế hoạch | Tương đương, cần giảng viên chấp nhận |
| Checkout, chi tiết đơn hàng | Xác nhận kế hoạch thành chiến dịch, xem chi tiết | Tương đương, cần giảng viên chấp nhận |
| Admin xem và cập nhật đơn hàng | Admin xem và chuyển trạng thái chiến dịch | Tương đương, cần giảng viên chấp nhận |
| SQLite | Lưu nháp câu trả lời trên điện thoại, mở lại và gửi khi có mạng | Bắt buộc |

Không tự kết luận đạt số điểm cụ thể trước khi giảng viên xác nhận cách quy đổi. Nếu cần giữ nguyên nghiệp vụ bán hàng, phải điều chỉnh phạm vi trước mốc triển khai kế hoạch và chiến dịch.

## 3. Thứ tự ưu tiên

### Bản bắt buộc

Xác thực, phân quyền, danh mục, mẫu và câu hỏi, ảnh, phân trang, trang chủ và tìm kiếm, kế hoạch, chiến dịch, thu thập phản hồi, SQLite lưu nháp và thống kê cơ bản.

### Mở rộng ưu tiên

Tìm kiếm/lọc ngày chiến dịch, mẫu liên quan có phân trang, chặn xóa mẫu đã dùng, ảnh danh mục. Chặn xóa mẫu đã dùng nên được làm ngay khi xây dựng ràng buộc dữ liệu.

### Để sau hoặc bỏ

Đăng nhập Google/Facebook/Zalo, thanh toán, xác thực email và quên mật khẩu, kéo thả thiết kế khảo sát, rẽ nhánh câu hỏi, đồng bộ hai chiều tự động, thống kê nâng cao. Không thêm nghiệp vụ thanh toán khi chưa có yêu cầu mua gói dịch vụ rõ ràng.

## 4. Kiến trúc và quy ước

```text
DOAN/
  cuoiki/
    survey_app/lib/
      models/
      repositories/
      pages/auth/
      pages/admin/
      pages/surveys/
      pages/campaigns/
      local/
      services/
      widgets/
      main.dart
    SurveyApi/
      Api/Controllers/
      Api/Models/
      Services/
      Database/
      wwwroot/uploads/
      Program.cs
  docs/
```

Toàn bộ mã nguồn, script database và cấu hình mẫu của ứng dụng đặt trong `DOAN/cuoiki/` theo yêu cầu người dùng. Tài liệu kế hoạch và minh chứng tiếp tục đặt trong `DOAN/docs/`.

- Học cách đặt tên model, `*_repository.dart`, `*_page.dart`, `fromMap` và luồng gọi `http` từ `trek_bikes_app`.
- Học cách tổ chức Controller, Repository, BaseRepository, SiteProvider và Dapper/SqlClient từ `WebApp`.
- Không sao chép cấu hình bí mật, tài khoản hoặc dữ liệu thật từ dự án mẫu.
- API trả lỗi HTTP và nội dung lỗi nhất quán; xác thực JWT, mật khẩu băm, truy vấn tham số hóa.
- Kiểm tra quyền tại API; việc ẩn nút trên Flutter chỉ phục vụ giao diện.
- SQL Server là nguồn chính; SQLite lưu dữ liệu cục bộ theo tài khoản. Token lưu secure storage.
- SQLite chỉ lưu nháp đã mở trên thiết bị; không làm hàng đợi nền hoặc đồng bộ hai chiều. Người dùng chủ động gửi khi có mạng, giữ mã gửi để tránh trùng khi thử lại.
- Để giữ lịch sử đơn giản: mẫu đã nằm trong chiến dịch thì không được sửa câu hỏi hoặc xóa; có thể tạo mẫu mới khi cần đổi nội dung. Chưa làm cơ chế phiên bản hoặc bản chụp khảo sát.
- Khi logout, loại bỏ dữ liệu cục bộ của phiên theo chính sách sẽ chốt ở mốc thiết kế, tránh lộ dữ liệu giữa tài khoản.
- Upload giới hạn loại/kích thước, tên file do máy chủ tạo; quy trình thay/xóa ảnh phải xét lỗi cơ sở dữ liệu và lỗi hệ thống file.

## 5. Các mốc và điều kiện kiểm tra

| Mốc | Công việc | Sản phẩm kiểm tra | Điều kiện hoàn thành |
| --- | --- | --- | --- |
| 1 | Chốt phạm vi và lộ trình | README và tài liệu này | Người dùng xem xét vai trò, quy đổi và phần bỏ qua |
| 2 | Thiết kế ngắn gọn | Một tài liệu gồm bảng dữ liệu, quyền, API và danh sách màn hình | Đủ rõ để viết code; không làm bộ hồ sơ thiết kế dài |
| 3 | Khởi tạo Flutter, API, SQL Server, SQLite | Hai dự án chạy tối thiểu, cấu hình mẫu, script DB và hướng dẫn chạy | API health chạy; kiểm tra kết nối SQL riêng; app gọi API và đọc/ghi SQLite trên điện thoại/emulator |
| 4 | Xác thực và quản trị tài khoản | Màn hình và API đăng ký/đăng nhập/đổi mật khẩu/logout/member/role | Không tự đăng ký Admin; kiểm tra 401/403, tài khoản khóa và cách vô hiệu hóa phiên |
| 5 | Danh mục và mẫu khảo sát | CRUD, câu hỏi, upload ảnh, phân trang | Chặn xóa sai; thêm/thay/xóa ảnh đúng; kiểm tra quyền sở hữu |
| 6 | Trang chủ và tra cứu | Danh sách mới nhất, danh mục, tìm kiếm, chi tiết, mẫu liên quan | Kết quả/lọc/phân trang đúng, có trạng thái tải/rỗng/lỗi |
| 7 | Kế hoạch và chiến dịch | Badge, thêm/sửa/xóa mẫu, xác nhận, chi tiết và quản trị chiến dịch | Tạo chiến dịch bằng transaction, chống xác nhận trùng, khóa sửa câu hỏi của mẫu đã dùng, chuyển trạng thái hợp lệ |
| 8 | Trả lời và lưu nháp | Điền khảo sát, SQLite lưu nháp và gửi chủ động | Khởi động lại vẫn có nháp; gửi lại không trùng; kiểm tra chiến dịch đóng và câu hỏi bắt buộc |
| 9 | Thống kê và mở rộng ưu tiên | Tổng hợp phản hồi, lọc ngày/tìm chiến dịch, hoàn thiện ảnh danh mục nếu có | Đối chiếu thống kê bằng bộ phản hồi mẫu biết trước |
| 10 | Hoàn thiện và bàn giao | Dữ liệu demo, hướng dẫn cài/chạy, bảng minh chứng, kịch bản bảo vệ | Chạy luồng chính trên điện thoại/emulator; kiểm tra API, quyền, ảnh, phân trang và offline |

Mỗi mốc kết thúc bằng: tóm tắt thay đổi, cách chạy/kiểm tra, kết quả kiểm tra thực tế và hạn chế còn lại. Không báo đạt khi chưa chạy được kiểm tra tương ứng.

## 6. Quy tắc kiểm thử

- Chạy formatter, phân tích tĩnh và build phù hợp với từng phần thay đổi.
- Kiểm thử tập trung vào quyền Admin/Member và quyền sở hữu, xác thực, ràng buộc xóa/sửa, transaction, chống gửi trùng và tính đúng của thống kê.
- Kiểm tra giao diện bằng thao tác trên ứng dụng; SQLite phải được kiểm tra trên môi trường di động, không dùng chạy web làm bằng chứng thay thế.
- Chỉ dùng dữ liệu demo; cấu hình máy và bí mật để ngoài mã nguồn, có file mẫu hướng dẫn.
- Nếu SQL Server hoặc emulator chưa sẵn sàng, ghi rõ phần chưa kiểm tra thay vì thay bằng database/công nghệ khác.

## 7. Chuẩn bị cho báo cáo Word về sau

Hiện chưa có yêu cầu tạo báo cáo Word. Trong quá trình phát triển, lưu tài liệu và minh chứng theo từng mốc để sau này biên soạn báo cáo từ hệ thống thực tế.

| Giai đoạn | Nội dung cần lưu | Phần báo cáo có thể sử dụng |
| --- | --- | --- |
| Mốc 1 | Mục tiêu, phạm vi, đối chiếu chức năng tương đương | Giới thiệu đề tài |
| Mốc 2 | Yêu cầu, bảng quyền, luồng sử dụng, ERD, từ điển dữ liệu, thiết kế màn hình | Phân tích và thiết kế |
| Mốc 3 | Phiên bản công cụ thực tế, kiến trúc, hướng dẫn cấu hình và chạy | Công nghệ và môi trường triển khai |
| Mốc 4–7 | Quy tắc nghiệp vụ, API, ảnh các chức năng đã chạy | Xây dựng ứng dụng |
| Mốc 8 | Schema SQLite, quy trình lưu nháp và gửi lại, tình huống mất mạng | Lưu trữ cục bộ |
| Mốc 9 | Công thức thống kê, dữ liệu mẫu, kết quả đối chiếu | Kết quả khảo sát |
| Mốc 10 | Kịch bản và kết quả kiểm thử, hạn chế, hướng phát triển | Kiểm thử, đánh giá và kết luận |

Quy tắc lưu minh chứng:

- Tài liệu đặt trong `docs/`; cập nhật theo thiết kế và mã nguồn cuối cùng.
- Khi có ảnh hoặc kết quả kiểm thử thực tế, lưu trong `docs/evidence/` theo mốc với tên mô tả chức năng. Chưa tạo minh chứng giả hoặc thư mục ảnh rỗng.
- Dùng dữ liệu demo; che token, mật khẩu, chuỗi kết nối và thông tin cá nhân trước khi lưu ảnh hoặc log.
- Kiểm thử quan trọng ghi môi trường, thao tác, kết quả mong đợi và kết quả thực tế.
- Ghi nguồn tham khảo khi sử dụng, bao gồm hai dự án mẫu; không tạo nguồn chưa đọc hoặc kết quả chưa kiểm tra.

Khi được yêu cầu làm Word: tiếp nhận mẫu/quy định của trường nếu có, thống nhất bố cục và thông tin sinh viên, tổng hợp tài liệu đã lưu, bổ sung ảnh và chú thích, rồi tạo và kiểm tra bố cục file `.docx`. Chỉ mô tả chức năng đã thực hiện; phần chưa làm đưa vào hạn chế hoặc hướng phát triển. Chưa ấn định số trang khi chưa biết quy định báo cáo.

## 8. Trạng thái hiện tại

Theo yêu cầu mới, đã code liên tục toàn bộ chức năng bắt buộc theo phương án khảo sát, giữ giao diện và kiến trúc đơn giản. Chưa làm nhóm điểm cộng tùy chọn. Xem `mandatory-build-check.md` cho kết quả tự kiểm tra và `full-test-checklist.md` để nghiệm thu trên điện thoại; các tài liệu kiểm tra trước đó giữ làm lịch sử.
