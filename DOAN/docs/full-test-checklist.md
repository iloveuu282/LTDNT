# Hướng dẫn test toàn bộ bản bắt buộc

## 1. Chạy bản mới

Database trên máy hiện tại đã được cập nhật, tài khoản cũ được giữ nguyên. Dừng hai terminal cũ bằng Ctrl+C, cắm điện thoại và chạy lại:

Terminal API:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\SurveyApi
dotnet run
```

Terminal Flutter:

```powershell
cd E:\Zhoc\LTDNT\DOAN\cuoiki\survey_app
flutter run
```

Chọn điện thoại Android. Không chỉ hot reload: bản mới có thêm thư viện chọn ảnh và nâng SQLite từ phiên bản 1 lên 2. API phải chạy bản mới vì có thêm endpoint.

Giữ cáp USB trong khi test online. Nếu vừa cắm lại cáp, khởi động lại API để thiết lập cổng USB. Khi test offline, dừng API thay vì rút cáp; chạy lại API để khôi phục kết nối.

## 2. Chuẩn bị

- Admin: dùng tài khoản đã được cấp quyền của bạn; nếu menu chưa đúng, đăng xuất và đăng nhập lại.
- Đăng ký hai Member thử, ví dụ `member1@example.com`, `member2@example.com`. Ghi nhớ mật khẩu tự chọn.
- Chuẩn bị hai ảnh PNG hoặc JPEG trong điện thoại, mỗi ảnh dưới 5 MB.
- Mẫu A sẽ được triển khai; mẫu B dùng thử sửa/xóa. Sau khi mẫu nằm trong chiến dịch, hệ thống khóa sửa/xóa để giữ nguyên dữ liệu phản hồi.
- Dùng danh mục và tài khoản thử để thực hiện thao tác xóa. Không thử xóa tài khoản Admin đang dùng.

## 3. Tài khoản và phân quyền

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| A1 | Đăng ký Member mới | Thành công; đăng nhập thấy Member |
| A2 | Đăng ký lại email đã dùng | Báo email trùng |
| A3 | Đăng nhập sai mật khẩu, rồi thử đúng | Sai bị từ chối; đúng vào trang chủ |
| A4 | Mở Đổi mật khẩu, thử sai mật khẩu hiện tại và xác nhận mới không khớp | Báo lỗi, không đổi |
| A5 | Đổi mật khẩu đúng | Quay về đăng nhập; mật khẩu cũ không dùng được, mật khẩu mới dùng được |
| A6 | Admin mở Thành viên và vai trò; sửa tên Member thử | Danh sách và dữ liệu thay đổi đúng; Member đó cần đăng nhập lại |
| A7 | Admin khóa Member, thử đăng nhập; mở khóa rồi thử lại | Khóa bị từ chối; mở khóa đăng nhập được |
| A8 | Gán Member thử thành Admin, đăng nhập lại; sau đó Admin gốc đổi lại Member | Menu và quyền thay đổi theo role; token trước đó không tiếp tục có quyền cũ |
| A9 | Kiểm tra tài khoản đang đăng nhập tại màn hình quản trị | Có nhãn Bạn; không có nút tự sửa/xóa |
| A10 | Xóa Member chỉ dùng để thử và chưa có dữ liệu liên quan | Không còn trong danh sách; không đăng nhập được |
| A11 | Đăng nhập Member bình thường | Không thấy Danh mục, Thêm mẫu, Thành viên và vai trò; API cũng chặn thao tác quản trị |
| A12 | Đăng xuất rồi bấm Back | Không quay lại trang trước đăng xuất; nháp của tài khoản đó đã xóa theo xác nhận |

Hai role Admin và Member được giữ cố định. Quản lý role ở đây là xem và gán role cho thành viên, không có tạo role tùy ý.

## 4. Danh mục

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| B1 | Admin mở Danh mục | Hiển thị danh sách |
| B2 | Thêm danh mục `Dịch vụ thử nghiệm` | Thành công, xuất hiện trong danh sách và bộ lọc trang chủ |
| B3 | Thêm tên trùng hoặc để tên rỗng | Bị từ chối |
| B4 | Sửa tên/mô tả danh mục | Hiển thị giá trị mới |
| B5 | Thêm một danh mục rỗng khác rồi xóa | Xóa được |
| B6 | Sau khi tạo mẫu A ở bước kế tiếp, thử xóa danh mục của mẫu A | Bị chặn vì danh mục còn mẫu |

## 5. Mẫu khảo sát, câu hỏi và ảnh

Admin chọn Thêm mẫu ngay trên trang chủ.

Tạo mẫu A với tên `Khảo sát hài lòng`, chọn danh mục, mô tả và ảnh. Thêm bốn câu hỏi:

1. Văn bản, bắt buộc: `Bạn góp ý gì?`.
2. Chọn một, bắt buộc: `Bạn có hài lòng không?`, lựa chọn `Có` và `Không`.
3. Chọn nhiều, bắt buộc: `Điểm bạn quan tâm?`, lựa chọn `Giá`, `Chất lượng`, `Dịch vụ`.
4. Thang điểm, bắt buộc: `Bạn đánh giá bao nhiêu điểm?`.

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| C1 | Thử lưu khi thiếu tên/danh mục/mô tả/câu hỏi hoặc ảnh khi thêm mới | Báo thiếu dữ liệu |
| C2 | Thêm/sửa/xóa câu hỏi trước khi lưu mẫu | Nội dung và thứ tự hiển thị đúng; câu chọn đáp án yêu cầu từ hai lựa chọn khác nhau |
| C3 | Lưu mẫu A đủ dữ liệu | Mẫu xuất hiện đầu danh sách, có ảnh và đúng danh mục |
| C4 | Mở chi tiết | Hiển thị tên, ảnh, mô tả và đủ câu hỏi |
| C5 | Khi mẫu A chưa triển khai, sửa mô tả và không chọn ảnh mới | Nội dung đổi, ảnh giữ nguyên |
| C6 | Sửa mẫu A và chọn ảnh thứ hai | Ảnh đổi; file ảnh cũ trên API được xóa |
| C7 | Tạo mẫu B chưa triển khai rồi xóa | Mẫu và file ảnh kèm theo bị xóa |
| C8 | Sau khi tạo chiến dịch dùng A, thử sửa/xóa A | Sửa bị khóa; xóa bị API từ chối |

Kiểm tra file ảnh tại `DOAN/cuoiki/SurveyApi/wwwroot/uploads/`. Tên file do máy chủ tạo. Nếu ảnh cũ còn hiển thị do cache, thoát trang chi tiết rồi mở lại. API kiểm tra chữ ký file PNG/JPEG và giới hạn 5 MB.

## 6. Trang chủ, tìm kiếm và phân trang

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| D1 | Trang chủ | Hiển thị các danh mục và mẫu mới nhất trước |
| D2 | Chọn từng danh mục rồi chọn Tất cả danh mục | Chỉ hiện mẫu của danh mục đã chọn; Tất cả bỏ lọc |
| D3 | Tìm `hài lòng`, rồi tìm từ không có | Có kết quả đúng hoặc thông báo không có mẫu phù hợp |
| D4 | Tạo ít nhất 11 mẫu để test nút trang sau/trước | Mỗi trang tối đa 10; tổng và số trang đúng, không lặp/mất mẫu |
| D5 | Khi có trên 10 kết quả cùng danh mục/từ khóa, chuyển trang | Giữ nguyên bộ lọc và từ khóa |

Phân trang API đã được kiểm tra tự động với 12 mẫu tạm; script xóa dữ liệu kiểm thử sau khi chạy. Nếu không muốn nhập 11 mẫu bằng tay, có thể đối chiếu phần này với kết quả kiểm thử API trước, rồi bổ sung dữ liệu demo khi cần trình bày.

## 7. Kế hoạch triển khai — tương đương giỏ hàng

Đăng nhập Member 1 và mở chi tiết mẫu A.

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| E1 | Bấm Thêm vào kế hoạch rồi quay lại trang chủ | Icon túi có badge số mẫu khác nhau |
| E2 | Thêm lại cùng mẫu A | Không tạo dòng trùng, không tự tăng chỉ tiêu |
| E3 | Thêm một mẫu khác rồi mở icon túi | Hiện hai mẫu và tổng phản hồi mục tiêu |
| E4 | Sửa chỉ tiêu A thành 3; thử nhập 0/số âm/chữ | 3 lưu được; giá trị không hợp lệ bị chặn |
| E5 | Bỏ mẫu khác khỏi kế hoạch rồi quay về trang chủ | Dòng bị xóa; badge còn 1 |
| E6 | Đăng nhập Member 2 | Kế hoạch riêng, không thấy kế hoạch Member 1 |
| E7 | Member 1 nhập tên chiến dịch và xác nhận | Tạo chiến dịch Chờ duyệt; kế hoạch được làm trống; mở chi tiết đúng mẫu và chỉ tiêu 3 |
| E8 | Xem Chiến dịch của tôi | Có chiến dịch vừa tạo; Member không thấy chiến dịch riêng chưa mở của người khác |

Icon đếm số mẫu khác nhau; chỉ tiêu từng mẫu là số phản hồi mục tiêu, không phải tiền hoặc số sản phẩm mua.

## 8. Quản lý chiến dịch — tương đương quản lý đơn hàng

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| F1 | Admin mở Quản lý chiến dịch | Thấy chiến dịch của mọi Member, có phân trang |
| F2 | Mở chiến dịch Member 1 vừa tạo | Đúng tên, người tạo, trạng thái, mẫu và chỉ tiêu |
| F3 | Admin bấm Mở chiến dịch | Chuyển Chờ duyệt → Đang mở |
| F4 | Member 2 mở Khảo sát đang mở | Thấy chiến dịch để tham gia; không thấy nút đổi trạng thái |
| F5 | Tạo một chiến dịch thử khác, Admin hủy khi Chờ duyệt | Chuyển Đã hủy và không nhận phản hồi |
| F6 | Sau khi test phản hồi, Admin đóng chiến dịch A | Chuyển Đã đóng; không nhận phản hồi mới, không mở lại |

Luồng trạng thái: Chờ duyệt → Đang mở hoặc Đã hủy; Đang mở → Đã đóng.

## 9. Trả lời khảo sát và SQLite

Thực hiện trước khi đóng chiến dịch A. Dùng Member 2 để trả lời.

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| G1 | Bấm Trả lời khảo sát, thử gửi khi chưa điền câu bắt buộc | Báo câu còn thiếu |
| G2 | Điền văn bản, chọn Có, chọn Giá và Chất lượng, chấm 5 | Các lựa chọn hiển thị đúng |
| G3 | Bấm Lưu nháp SQLite, quay về Nháp SQLite | Có nháp của chiến dịch và mẫu vừa trả lời |
| G4 | Đóng hẳn app rồi mở lại, không đăng xuất | Khôi phục hồ sơ; mở Nháp SQLite thấy nội dung và lựa chọn đã lưu |
| G5 | Dừng API, mở nháp đã lưu và sửa nội dung; bấm lưu nháp | Vẫn đọc/ghi nháp trên điện thoại được |
| G6 | Khi API còn dừng, thử gửi | Không báo gửi thành công; nháp vẫn được giữ |
| G7 | Chạy lại API bằng dotnet run, mở nháp và gửi | Gửi thành công; nháp tương ứng biến mất |
| G8 | Mở lại chiến dịch | Ghi Bạn đã trả lời; không có nút gửi lần hai cho mẫu đó |
| G9 | Đăng xuất với một nháp thử khác chưa gửi | Có xác nhận xóa nháp; nháp không xuất hiện ở tài khoản khác |
| G10 | Khi mẫu đủ chỉ tiêu hoặc chiến dịch đã đóng, thử gửi nháp cũ bằng tài khoản chưa gửi | API từ chối, nháp được giữ để người dùng tự xử lý/xóa |

Mỗi tài khoản trả lời một lần cho mỗi mẫu trong một chiến dịch. Vì vậy, để có ba phản hồi cần ba tài khoản. Chỉ các mẫu/nháp đã mở và lưu mới dùng được offline; không tải toàn bộ hệ thống về điện thoại.

## 10. Kết quả và ràng buộc

| Mã | Thao tác | Kết quả mong đợi |
| --- | --- | --- |
| H1 | Member 1 hoặc Admin mở chi tiết chiến dịch → Xem kết quả | Tổng phản hồi và kết quả từng câu đúng |
| H2 | Nếu mới có một phản hồi ở G2 | Tổng 1; Có = 1; Giá = 1; Chất lượng = 1; Dịch vụ = 0; điểm trung bình 5 |
| H3 | Member 2 chỉ là người tham gia | Không có nút xem kết quả của chiến dịch người khác; API cũng chặn |
| H4 | Admin thử xóa Member đã tạo chiến dịch hoặc gửi phản hồi | Báo có dữ liệu liên quan; dùng khóa tài khoản thay vì xóa |

Tỷ lệ lựa chọn tính trên tổng số phản hồi; câu chọn nhiều có thể có tổng tỷ lệ lớn hơn 100%. Câu không bắt buộc có thể để trống.

## 11. Đối chiếu bảng chấm điểm

- Xác thực, thành viên, role và logout: nhóm A.
- CRUD danh mục và kiểm tra còn mẫu trước khi xóa: nhóm B.
- CRUD sản phẩm tương đương mẫu khảo sát, ảnh và phân trang: nhóm C–D.
- Trang chủ, danh mục, mới nhất, tìm kiếm, chi tiết: nhóm D.
- Giỏ hàng tương đương kế hoạch, badge, thêm/sửa/xóa, checkout và chi tiết: nhóm E.
- Admin quản lý đơn hàng tương đương quản lý chiến dịch và trạng thái: nhóm F.
- Phù hợp đề tài và lưu trữ SQLite: nhóm G–H.

Cách quy đổi kế hoạch/chiến dịch cần được giải trình với giảng viên; không tự khẳng định số điểm được công nhận. Đã bổ sung mẫu liên quan và tìm/lọc ngày chiến dịch; xem `simple-bonus-check.md`. Chưa làm email, mạng xã hội, thanh toán và ảnh danh mục.

## 12. Gửi lỗi để sửa

Gửi mã bước (ví dụ C6 hoặc G7), tài khoản đang dùng là Admin/Member, thao tác trước lỗi, ảnh màn hình và log terminal nếu có. Với chức năng đã chạy đúng, có thể chụp ảnh làm minh chứng báo cáo về sau; không chụp mật khẩu hoặc token.
