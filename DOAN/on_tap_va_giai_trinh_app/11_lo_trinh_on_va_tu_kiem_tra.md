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
