# Sửa tràn bố cục trang chủ khi xoay ngang và mở bàn phím

Ngày: 19/11/2026.

Người dùng gửi ảnh có BOTTOM OVERFLOWED BY 142 PIXELS. Đã tái hiện cùng loại lỗi bằng widget test với viewport 850×393 và bàn phím cao 260: bản cũ báo RenderFlex overflow 76 pixels. Số pixel khác nhau theo kích thước thiết bị; nguyên nhân cùng là chiều cao các vùng cố định lớn hơn phần thân màn hình còn lại.

## Thay đổi

- HomePage chuyển phần hồ sơ/menu thành header của danh sách khảo sát.
- SurveyListView dùng một ListView chung cho header, tìm kiếm, danh mục, kết quả và phân trang. Bỏ Column và Expanded chia chiều cao cố định theo chiều dọc.
- Khi không đủ chiều cao, nội dung cuộn thay vì tràn. Kéo danh sách có thể đóng bàn phím.
- Không đổi API, dữ liệu hoặc các thao tác nghiệp vụ.

## Kiểm tra

- Test tái hiện trước sửa: thất bại vì RenderFlex overflow.
- Sau sửa: cùng viewport không tràn; 6 test hiện có đạt. Bổ sung kiểm tra cuộn tới và nhập được ô tìm kiếm trong chế độ này.
- Flutter analyze: không có lỗi/cảnh báo trong lần kiểm tra sau sửa bố cục.
- Kiểm tra cuối: 6 test đạt, gồm cuộn tới và nhập ô tìm kiếm trong viewport ngang có bàn phím; APK debug build thành công.
- Thông báo mất kết nối ở ảnh thứ hai là nhánh dự kiến: gửi không thành công, giữ nháp. Kiểm tra lúc xử lý ảnh: health API localhost:5080 trả ok, adb reverse có tcp:5080 → tcp:5080. Không tự gửi phản hồi của người dùng.

Người dùng cần nhận code mới bằng hot restart (R trong terminal flutter run) hoặc chạy lại flutter run rồi thử xoay ngang, mở bàn phím và cuộn trang chủ.
