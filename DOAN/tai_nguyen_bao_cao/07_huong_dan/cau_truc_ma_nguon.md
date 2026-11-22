# Cấu trúc mã nguồn dùng để giải trình

```text
DOAN/cuoiki
├── survey_app
│   ├── lib/main.dart                 Khởi tạo ứng dụng, database và phiên
│   ├── lib/models                    Mô hình dữ liệu Dart
│   ├── lib/repositories              Gọi API cho từng nhóm nghiệp vụ
│   ├── lib/pages                     Màn hình và biểu mẫu
│   ├── lib/services                  Kết nối API, lưu phiên và cấu hình
│   ├── lib/local/local_database.dart SQLite nháp
│   ├── lib/widgets                   Thành phần giao diện dùng lại
│   ├── test                          Kiểm thử Flutter
│   └── integration_test              Kiểm thử thiết bị, không phải màn hình người dùng
├── SurveyApi
│   ├── Program.cs                    Khởi tạo REST API, JWT và static files
│   ├── Api/Controllers               Endpoint, quyền và kiểm tra đầu vào
│   ├── Api/Models                    Model, Repository, SiteProvider và SQL Dapper
│   ├── Services/ImageService.cs      Kiểm tra, lưu và xóa ảnh
│   ├── Database                      Script SQL Server
│   └── wwwroot/uploads               File ảnh được upload
├── tests/full_api_check.ps1           Bộ kiểm thử API bằng dữ liệu tạm
└── enable-wifi.ps1                    Cho phép cổng API trong mạng nội bộ
```

Tên lớp hàm và URL có thể còn dùng checkout theo cấu trúc tiêu chí gốc; giao diện và phần giải trình gọi nghiệp vụ là tạo chiến dịch. Không khẳng định áp dụng mô hình kiến trúc phức tạp khác khi mã nguồn hiện dùng Page/Repository và Controller/Repository đơn giản.
