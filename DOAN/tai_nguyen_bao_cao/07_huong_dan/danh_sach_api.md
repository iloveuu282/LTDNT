# Danh sách API chính

Tất cả đường dẫn dưới bắt đầu bằng /api. Trừ đăng ký, đăng nhập và health, các endpoint cần JWT. Tên endpoint giữ nguyên trong mã nguồn.

| Phương thức và đường dẫn | Quyền và mục đích |
| --- | --- |
| GET /health | Không cần đăng nhập, kiểm tra máy chủ phản hồi |
| POST /auth/register | Không cần đăng nhập, tạo Member |
| POST /auth/login | Không cần đăng nhập, nhận token và hồ sơ |
| GET /auth/me | Tài khoản đang đăng nhập |
| POST /auth/change-password | Đổi mật khẩu của mình |
| POST /auth/logout | Thu hồi phiên |
| GET /members; GET /members/roles | Admin xem thành viên và vai trò |
| PUT /members/{id}; DELETE /members/{id} | Admin cập nhật hoặc xóa theo ràng buộc |
| GET /categories | Xem danh mục |
| POST /categories; PUT /categories/{id} | Admin, multipart/form-data; categoryName, description, image tùy chọn, removeImage |
| DELETE /categories/{id} | Admin, chặn danh mục còn mẫu |
| GET /surveys | page, pageSize, categoryId, search |
| GET /surveys/{id} | Chi tiết mẫu |
| GET /surveys/{id}/related | Mẫu cùng danh mục; page, pageSize |
| POST /surveys; PUT /surveys/{id} | Admin, multipart/form-data; categoryId, title, description, questionsJson, image |
| DELETE /surveys/{id} | Admin, mẫu chưa dùng |
| GET /plan | Kế hoạch của tài khoản hiện tại |
| PUT /plan/{surveyId}; DELETE /plan/{surveyId} | Thêm/sửa targetCount hoặc bỏ mẫu |
| POST /plan/checkout | Tạo chiến dịch từ kế hoạch; title và requestId |
| GET /campaigns | Danh sách theo quyền; open, page, pageSize, search, fromDate, toDate |
| GET /campaigns/{id} | Chủ sở hữu/Admin, hoặc người xem chiến dịch đang mở |
| PUT /campaigns/{id}/status | Admin, chuyển trạng thái hợp lệ |
| POST /campaigns/{id}/items/{itemId}/responses | Gửi submissionId và answers; kiểm tra trạng thái, chỉ tiêu và chưa trả lời |
| GET /campaigns/{id}/items/{itemId}/results | Chủ chiến dịch hoặc Admin |

Trang mặc định 10 phần tử, pageSize API cho phép 1–50. Không đưa token thực tế hoặc mật khẩu vào ví dụ báo cáo.
