from pathlib import Path
import ast
import csv
import json
import shutil

DOAN = Path(__file__).resolve().parents[1]
ROOT = DOAN / 'tai_nguyen_bao_cao'

def write(name, content):
    path = ROOT / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.strip() + '\n', encoding='utf-8')

write('README.md', '''
# Tài nguyên làm báo cáo Word

Đề tài: Xây dựng ứng dụng hỗ trợ khảo sát cho doanh nghiệp.
Cập nhật ngày 19/11/2026, sau khi bổ sung ảnh danh mục và người dùng xác nhận dùng qua Wi-Fi ổn.

## Đọc và sử dụng theo thứ tự

| Thư mục | Nội dung | Dùng trong Word |
| --- | --- | --- |
| 01_noi_dung | Đề cương, nội dung mô tả, giải trình và câu hỏi thường gặp | Viết các chương và phần kết luận |
| 02_doi_chieu | Bảng yêu cầu cập nhật dạng Markdown và CSV, ma trận quyền | Chèn bảng đối chiếu và bảng phân quyền |
| 03_so_do | Ảnh PNG độ phân giải cao và mã nguồn Mermaid | Insert → Pictures để chèn PNG; có thể sửa sơ đồ từ file nguồn |
| 04_co_so_du_lieu | Script tạo/cập nhật SQL Server, schema SQLite và từ điển dữ liệu | Chương thiết kế và phụ lục |
| 05_kiem_thu | Log API, minh chứng SQLite Android, mô tả kết quả và mẫu bảng kiểm thử thực tế | Chương kiểm thử |
| 06_anh_minh_chung | Các thư mục ảnh theo chức năng, danh sách ảnh và chú thích dự kiến | Chèn ảnh thao tác thực tế trên app |
| 07_huong_dan | Hướng dẫn chạy, danh sách API, cấu trúc mã nguồn và danh sách hồ sơ nộp | Phần triển khai và phụ lục |

Ảnh sơ đồ đã được xuất PNG để chèn trực tiếp vào Word. CSV dùng UTF-8 có BOM để mở bằng Excel; chọn bảng rồi sao chép vào Word hoặc dùng bản Markdown làm nguồn nội dung.

Các thư mục ảnh chức năng được tạo sẵn nhưng chưa đủ ảnh. Đọc 06_anh_minh_chung/danh_sach_anh_can_chup.md rồi chụp trên bản app cuối. Ảnh thử nghiệm cũ nằm riêng trong kiem_thu_ky_thuat và tham_khao_cu; không dùng ảnh đang tải làm bằng chứng chức năng đã thành công.

Trước khi nộp: điền tên trường, môn học, sinh viên, MSSV, lớp và giảng viên trong đề cương; thay ảnh minh chứng; hoàn thành bảng kiểm thử thực tế. Thư mục này là tài nguyên để soạn báo cáo, chưa phải báo cáo Word cuối cùng.

Không có mật khẩu, token JWT, khóa ký, khóa .local-jwt-key, database chứa tài khoản thật hoặc cấu hình bí mật trong bộ tài nguyên. Ảnh chụp cần che thông tin cá nhân không cần thiết. Các script database là schema, không phải bản sao lưu dữ liệu thực tế.

Bảng đối chiếu ở 02_doi_chieu là bản cập nhật; file Word đối chiếu trước đây trong DOAN/docs được tạo trước lúc bổ sung ảnh danh mục nên không sao chép vào đây để tránh dùng nhầm trạng thái cũ.
''')

write('01_noi_dung/01_de_cuong_bao_cao.md', '''
# Đề cương báo cáo

## Thông tin cần điền

- Trường và khoa: [Điền thông tin]
- Môn học: [Điền thông tin]
- Giảng viên hướng dẫn: [Điền thông tin]
- Sinh viên, MSSV và lớp: [Điền thông tin]
- Tên đề tài: Xây dựng ứng dụng hỗ trợ khảo sát cho doanh nghiệp
- Thời gian thực hiện: [Điền thời gian thực tế]

## Cấu trúc đề nghị

1. Trang bìa và mục lục tự động trong Word.
2. Chương 1 Giới thiệu đề tài: bối cảnh, mục tiêu, đối tượng sử dụng, phạm vi.
3. Chương 2 Phân tích yêu cầu: nghiệp vụ, chức năng, phân quyền, quy tắc và luồng sử dụng.
4. Chương 3 Thiết kế hệ thống: kiến trúc, tổ chức mã nguồn, SQL Server, SQLite và REST API.
5. Chương 4 Kết quả triển khai: từng nhóm màn hình, ảnh minh chứng và mô tả thao tác.
6. Chương 5 Kiểm thử và đánh giá: môi trường, kết quả tự động, trường hợp kiểm thử thủ công, hạn chế.
7. Chương 6 Đối chiếu yêu cầu và giải trình chức năng tương đương.
8. Kết luận và hướng phát triển.
9. Tài liệu tham khảo và phụ lục hướng dẫn chạy, danh sách API, script database.

Không cần chép toàn bộ mã nguồn vào báo cáo. Chọn các đoạn tiêu biểu thực sự có trong dự án: kiểm tra quyền API, xử lý ảnh, transaction tạo chiến dịch/gửi phản hồi và lưu nháp SQLite. Trích tên file để có thể đối chiếu với mã nguồn nộp kèm.

Tạo tiêu đề chương bằng Heading 1, mục nhỏ bằng Heading 2; dùng Caption cho hình và bảng để Word tự tạo danh mục. Ưu tiên mẫu trình bày của trường nếu có, không ấn định số trang khi chưa biết yêu cầu môn học.
''')

write('01_noi_dung/02_noi_dung_mo_ta_he_thong.md', '''
# Nội dung mô tả hệ thống

## Bối cảnh và mục tiêu

Doanh nghiệp cần thu thập ý kiến khách hàng, nhân viên hoặc thị trường để đánh giá và cải thiện hoạt động. Việc quản lý nhiều mẫu câu hỏi và phản hồi rời rạc gây khó khăn khi triển khai và tổng hợp. Đề tài xây dựng ứng dụng trên điện thoại giúp quản lý mẫu khảo sát, chuẩn bị kế hoạch, triển khai chiến dịch, thu thập phản hồi và xem kết quả.

Ứng dụng được phát triển bằng Flutter với ngôn ngữ Dart. REST API viết bằng C# ASP.NET Core 10 xử lý nghiệp vụ và lưu dữ liệu tập trung trong SQL Server. SQLite trên điện thoại lưu nháp câu trả lời để người dùng tiếp tục nhập khi mất kết nối.

## Đối tượng và phạm vi

Admin quản trị thành viên và vai trò, danh mục, mẫu khảo sát, ảnh và trạng thái chiến dịch. Member là người dùng trong hệ thống có thể chuẩn bị kế hoạch, tạo chiến dịch, tham gia khảo sát đang mở và xem kết quả chiến dịch mình sở hữu. Admin có thể xem và quản trị các chiến dịch trong hệ thống.

Mô hình hiện tại không tách thêm vai trò doanh nghiệp, nhân viên và khách vãng lai. Người trả lời cần có tài khoản. Đây là ứng dụng dùng nội bộ hoặc trong cùng mạng với máy chủ; chưa có nghiệp vụ bán gói dịch vụ và thanh toán.

## Luồng nghiệp vụ chính

1. Admin tạo danh mục, mẫu khảo sát, ảnh và câu hỏi.
2. Người dùng chọn các mẫu vào kế hoạch và nhập số phản hồi mục tiêu cho từng mẫu.
3. Xác nhận kế hoạch để tạo chiến dịch ở trạng thái chờ duyệt.
4. Admin mở chiến dịch để người dùng tham gia; hoặc hủy khi còn chờ duyệt.
5. Người tham gia trả lời các câu hỏi và gửi phản hồi. Có thể lưu nháp trước khi rời trang.
6. Chủ chiến dịch hoặc Admin xem kết quả; Admin đóng chiến dịch khi kết thúc.

## Xác thực và phân quyền

Đăng ký tạo tài khoản Member. Đăng nhập đúng thông tin được API cấp JWT; mật khẩu được băm bằng BCrypt trong SQL Server. Token được lưu bằng Flutter Secure Storage, không lưu trong bảng nháp SQLite. API kiểm tra trạng thái tài khoản, phiên và vai trò trên mỗi yêu cầu xác thực.

Đổi mật khẩu và đăng xuất trực tuyến làm mất hiệu lực token cũ. Khi Admin sửa thông tin/quyền hoặc khóa tài khoản, tài khoản bị tác động cần đăng nhập lại. Giao diện ẩn chức năng quản trị với Member và server vẫn kiểm tra quyền; ẩn nút không thay cho phân quyền API.

Admin không chỉnh sửa hoặc xóa chính mình tại màn hình quản trị. Thành viên có chiến dịch hoặc phản hồi không được xóa; dùng khóa tài khoản để giữ lịch sử. Vai trò Admin và Member là hai vai trò cố định, chưa có chức năng tạo tên vai trò tùy ý.

## Danh mục và mẫu khảo sát

Danh mục gồm tên, mô tả và ảnh đại diện tùy chọn. Mẫu gồm danh mục, tiêu đề, mô tả, ảnh và danh sách câu hỏi. Thêm mẫu bắt buộc có ảnh; danh mục cũ không có ảnh dùng biểu tượng mặc định. Server nhận PNG/JPEG tối đa 5 MB, kiểm tra chữ ký định dạng và sinh tên file ngẫu nhiên.

Khi thay ảnh thành công, hệ thống xóa ảnh cũ; khi ghi dữ liệu thất bại, ảnh mới được dọn. Khi xóa danh mục hoặc mẫu được phép xóa, file ảnh đi kèm cũng được xóa. Danh mục còn mẫu không được xóa. Mẫu đã có trong bất kỳ chiến dịch nào không được sửa hoặc xóa, kể cả chiến dịch đã đóng/hủy, để giữ nội dung nhất quán với lịch sử.

Trang chủ có mẫu mới nhất, lọc danh mục, tìm theo tên và phân trang 10 mẫu mỗi trang. Chi tiết có mẫu liên quan cùng danh mục, không gồm chính mẫu đang xem và có phân trang.

## Kế hoạch và chiến dịch

Mỗi người dùng có kế hoạch riêng; cùng một mẫu chỉ có một dòng trong kế hoạch. Số phản hồi mục tiêu nằm trong khoảng 1 đến 100000. Badge kế hoạch đếm số mẫu khác nhau, không đếm tổng số phản hồi mục tiêu.

Tạo chiến dịch lưu các dòng kế hoạch thành chi tiết chiến dịch rồi làm trống kế hoạch trong một transaction. RequestId giúp gửi lại cùng yêu cầu không tạo chiến dịch trùng. Chiến dịch có thể tìm theo tên/mã, phân trang và lọc ngày tạo theo giờ Việt Nam. Member chỉ xem danh sách riêng của mình, còn danh sách đang mở dành cho các chiến dịch Active.

Trạng thái hợp lệ: Pending → Active hoặc Cancelled; Active → Closed. Chỉ Admin đổi trạng thái. Chủ chiến dịch và Admin có quyền xem kết quả; người chỉ tham gia không xem kết quả chiến dịch của người khác.

## Câu hỏi và phản hồi

Có bốn loại câu hỏi: văn bản, chọn một, chọn nhiều và đánh giá 1 đến 5. Câu hỏi có thể bắt buộc hoặc không bắt buộc. API kiểm tra câu trả lời theo loại, lựa chọn hợp lệ và số lượng phản hồi mục tiêu.

Mỗi tài khoản trả lời một lần cho mỗi mẫu trong một chiến dịch. SubmissionId giúp thử gửi lại cùng phản hồi mà không tạo bản ghi trùng. Hệ thống không cho gửi khi chiến dịch chưa mở, đã đóng hoặc đã đủ mục tiêu. Kết quả gồm số phản hồi, nội dung trả lời văn bản, số lượt chọn và điểm đánh giá trung bình. Câu chọn nhiều có thể có tổng tỷ lệ lớn hơn 100 phần trăm.

## SQLite và sử dụng không dây

Nháp hiện dùng bảng response_drafts, khóa ghép member_id và item_id. payload_json chứa mẫu, câu trả lời và mã gửi lại; nháp được phân tách theo tài khoản. Bảng survey_drafts là bảng cũ được giữ để tương thích phiên bản database, không phải nơi luồng trả lời hiện tại lưu nháp.

Lưu nháp là thao tác chủ động; các thay đổi chưa bấm Lưu nháp không được đảm bảo giữ lại. Nếu gửi lỗi, nháp đã lưu được giữ. Nháp không tự gửi nền. Đăng xuất xóa nháp của tài khoản trên điện thoại sau bước xác nhận.

App release chạy từ icon mà không cần terminal Flutter. Điện thoại dùng Wi-Fi để truy cập API trên máy tính; địa chỉ có thể thay trong Kết nối máy chủ và được lưu lại. Máy tính vẫn phải bật API và SQL Server. Không có mạng thì chỉ làm việc với các nháp đã lưu; chưa hỗ trợ toàn bộ hệ thống offline. Địa chỉ nội bộ không dùng được từ mọi mạng Internet.

## Kết quả và hướng phát triển

Đã triển khai nhóm chức năng bắt buộc theo nghiệp vụ khảo sát, cùng ảnh danh mục, mẫu liên quan có phân trang, tìm kiếm/lọc ngày chiến dịch và các ràng buộc bảo toàn dữ liệu. Kết quả kiểm thử tự động gần nhất gồm 134 lượt API và 10 kiểm thử Flutter; bản release build và cài cập nhật thành công. Người dùng đã xác nhận dùng qua Wi-Fi ổn.

Chưa triển khai xác thực email, quên mật khẩu và đăng nhập Google/Facebook/Zalo. Các phần này cần cấu hình dịch vụ bên ngoài và kiểm thử bổ sung. Thanh toán chưa phù hợp vì hiện không thu tiền. Nếu triển khai ra Internet, cần máy chủ HTTPS, cấu hình vận hành và khóa ký phát hành riêng.
''')

write('01_noi_dung/03_giai_trinh_va_cau_hoi.md', '''
# Giải trình chức năng và câu hỏi thường gặp

## Cách quy đổi nghiệp vụ

| Tiêu chí gốc | Chức năng trong đề tài | Lý do tương đương |
| --- | --- | --- |
| Sản phẩm | Mẫu khảo sát | Đối tượng được phân loại, có ảnh, danh sách, tìm kiếm và chi tiết |
| Danh mục sản phẩm | Danh mục khảo sát | Phân loại mẫu theo mục đích khách hàng, nhân sự hoặc thị trường |
| Giỏ hàng | Kế hoạch khảo sát | Tập hợp các mẫu trước khi triển khai, có thêm/sửa/xóa và badge |
| Số lượng sản phẩm | Số phản hồi mục tiêu | Chỉ tiêu thu thập cho từng mẫu |
| Checkout | Tạo chiến dịch | Xác nhận kế hoạch để lưu chiến dịch và chi tiết |
| Đơn hàng | Chiến dịch khảo sát | Có chủ sở hữu, chi tiết, trạng thái, tìm kiếm và lọc ngày |
| Sản phẩm liên quan | Mẫu cùng danh mục | Giúp lựa chọn các mẫu có cùng mục đích |

Đây là giải trình đề nghị công nhận chức năng tương đương, không phải cam kết số điểm. Không gọi các giao dịch trong hệ thống là mua bán khi trình bày nghiệp vụ.

## Tại sao vẫn có kế hoạch khảo sát

Doanh nghiệp có thể cần dùng nhiều mẫu trong một đợt thu thập ý kiến. Kế hoạch giúp chọn các mẫu và chỉ tiêu trước khi tạo chiến dịch. Đây là một bước chuẩn bị nghiệp vụ, không phải giỏ mua hàng có giá và tiền thanh toán.

## Tại sao không làm thanh toán

Hệ thống hiện không bán hàng hoặc bán gói khảo sát và không có khoản tiền cần thu. Việc thêm VNPayment/VietQR không có đầu vào nghiệp vụ phù hợp. Chỉ nên triển khai nếu mở rộng dịch vụ có thu phí.

## Member có quá nhiều quyền hay không

Member trong mô hình này là người dùng hệ thống của doanh nghiệp: có thể tạo chiến dịch, tham gia và xem kết quả chiến dịch mình tạo. Member không quản trị thành viên, danh mục, mẫu hoặc trạng thái. Nếu chỉ dành Member cho khách trả lời thì cần tách thêm vai trò trong một phiên bản mở rộng.

## SQLite và SQL Server khác nhau ở đâu

SQL Server là nguồn dữ liệu tập trung cho nghiệp vụ online. SQLite chỉ giữ bản nháp trên điện thoại. Token và cấu hình kết nối dùng Secure Storage. Không mô tả app là đã đồng bộ toàn bộ dữ liệu hoặc tự gửi nền vì chưa có chức năng đó.

## Tại sao mẫu đã triển khai không được sửa hoặc xóa

Sửa câu hỏi hoặc lựa chọn sau khi có chiến dịch có thể làm sai ý nghĩa các câu trả lời cũ. Hệ thống khóa mẫu khi đã nằm trong chiến dịch để bảo toàn lịch sử. Muốn khảo sát nội dung khác thì tạo mẫu mới.

## Tránh gửi trùng bằng cách nào

Checkout dùng RequestId duy nhất theo tài khoản. Phản hồi dùng SubmissionId và ràng buộc một người trả lời một lần trên mỗi CampaignItem. API dùng transaction và ràng buộc database để xử lý cả các yêu cầu đồng thời; không chỉ khóa nút trên giao diện.

## Rút dây có làm app ngừng chạy không

Không. Bản release chạy độc lập và gọi API qua Wi-Fi. Máy tính chạy máy chủ vẫn phải bật. Khi tắt mạng hoặc máy chủ dừng, nháp đã lưu vẫn dùng được, còn gửi phản hồi và quản trị cần kết nối.

## Phong cách tổ chức mã nguồn

Flutter học cách phân chia models, repositories, pages và services từ trek_bikes_app. API học cấu trúc Controller, SiteProvider và Repository từ WebApp; dùng Dapper để truy vấn SQL rõ ràng. Nội dung nghiệp vụ khảo sát, câu hỏi, chiến dịch và nháp được xây dựng theo đề tài. Không đưa mật khẩu hoặc khóa bí mật vào phần mã minh họa.

## Các phần còn lại

Email xác thực và quên mật khẩu: mức trung bình, cần dịch vụ email và mã dùng một lần có thời hạn. Đăng nhập mạng xã hội: cần tài khoản nhà cung cấp, OAuth và cấu hình ứng dụng. Thanh toán: chưa phù hợp phạm vi. Ảnh danh mục đã hoàn thành, không còn thuộc danh sách chưa làm.

## Trình tự trình bày khi cần

Đăng nhập Admin → danh mục/ảnh → mẫu/câu hỏi → Member chọn kế hoạch và tạo chiến dịch → Admin mở → người tham gia trả lời/lưu nháp → chủ chiến dịch xem kết quả. Có thể dùng ảnh để trình bày các bước thay vì phải luyện demo riêng. Không xóa dữ liệu thật để tạo tình huống lỗi.
''')

# Lấy các dòng tiêu chí từ bản đối chiếu đã soạn; chỉ đọc AST, không chạy trình tạo Word.
source = ast.parse((DOAN / 'docs/create_requirement_word.py').read_text(encoding='utf-8-sig'))
rows = []
for node in source.body:
    if not isinstance(node, ast.Expr) or not isinstance(node.value, ast.Call): continue
    call = node.value
    if not isinstance(call.func, ast.Name) or call.func.id not in ('row', 'done', 'pending'): continue
    args = [ast.literal_eval(a) for a in call.args]
    if call.func.id == 'row':
        rows.append(args[:4])
    elif call.func.id == 'done':
        title, score, note = args[:3]
        equivalent = args[3] if len(args) > 3 else False
        required = args[4] if len(args) > 4 else 'Bắt buộc'
        rows.append([title, required, score, ('Đã hoàn thành tương đương. ' if equivalent else 'Đã hoàn thành. ') + note])
    else:
        title, score, note = args[:3]
        if title.startswith('Upload ảnh danh mục'):
            rows.append([title, 'Điểm cộng', score, 'Đã hoàn thành. Upload khi thêm, thay ảnh thì xóa ảnh cũ, bỏ ảnh và xóa file khi xóa danh mục. Danh mục còn mẫu bị chặn xóa và giữ ảnh; lỗi lưu dọn ảnh mới.'])
        else: rows.append([title, 'Điểm cộng', score, 'Chưa làm. ' + note])
path = ROOT / '02_doi_chieu/yeu_cau_va_tien_do.csv'
path.parent.mkdir(parents=True, exist_ok=True)
with path.open('w', newline='', encoding='utf-8-sig') as f:
    writer = csv.writer(f); writer.writerow(['Chức năng', 'Yêu cầu', 'Điểm theo đề', 'Trạng thái và giải trình']); writer.writerows(rows)
table = ['# Đối chiếu yêu cầu và tiến độ', '', 'Cập nhật sau khi hoàn thành ảnh danh mục và chạy Wi-Fi. Điểm giữ theo bảng yêu cầu, không tự quy thành điểm cuối cùng. Các phần chuyển đổi nghiệp vụ cần giảng viên công nhận.', '', '| Chức năng | Yêu cầu | Điểm theo đề | Trạng thái và giải trình |', '| --- | --- | --- | --- |']
table += ['| ' + ' | '.join(str(v).replace('|', '/') for v in row) + ' |' for row in rows]
table += ['', 'Lưu ý: nhóm trang chủ trong đề ghi tổng 1.75 điểm chức năng, nhưng các dòng bắt buộc cộng được 1.5 điểm. Giữ nguyên số đề và hỏi giảng viên cách tính; không tự cộng hoặc khẳng định điểm được nhận.', '', 'Chưa làm: xác thực email (0.5), quên mật khẩu (0.5), Google/Facebook/Zalo (1.5), VNPayment/VietQR (1.0). Tổng tiêu chí điểm cộng chưa làm là 3.5 điểm thô. Ảnh danh mục 0.75 đã được bổ sung.']
write('02_doi_chieu/yeu_cau_va_tien_do.md', '\n'.join(table))

write('02_doi_chieu/ma_tran_phan_quyen.md', '''
# Ma trận phân quyền

| Chức năng | Chưa đăng nhập | Member | Admin |
| --- | --- | --- | --- |
| Đăng ký và đăng nhập | Có | Đăng xuất trước để đổi tài khoản | Đăng xuất trước để đổi tài khoản |
| Cấu hình kết nối máy chủ | Có | Có | Có |
| Xem danh mục, mẫu, tìm kiếm, chi tiết | Không | Có | Có |
| Thêm/sửa/xóa danh mục, ảnh | Không | Không | Có, theo ràng buộc dữ liệu |
| Thêm/sửa/xóa mẫu và câu hỏi | Không | Không | Có; mẫu đã dùng bị khóa sửa/xóa |
| Quản lý thành viên và gán Admin/Member | Không | Không | Có; không tự sửa/xóa mình |
| Kế hoạch và tạo chiến dịch | Không | Kế hoạch riêng | Kế hoạch riêng |
| Danh sách chiến dịch | Không | Của mình | Toàn bộ |
| Danh sách chiến dịch đang mở và tham gia | Không | Có | Có |
| Đổi trạng thái chiến dịch | Không | Không | Có, đúng luồng trạng thái |
| Xem kết quả | Không | Chiến dịch mình sở hữu | Có |
| Đổi mật khẩu, đăng xuất | Không | Tài khoản của mình | Tài khoản của mình |
| Nháp SQLite | Không đăng nhập mới được khi offline | Nháp của tài khoản đã lưu phiên | Nháp của tài khoản đã lưu phiên |

Quyền API được kiểm tra phía server. Hồ sơ lưu trên điện thoại chỉ giúp mở lại app và nháp; không cấp quyền truy cập server khi token hết hạn hoặc tài khoản đã bị khóa.
''')

write('04_co_so_du_lieu/tu_dien_du_lieu.md', '''
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
''')
write('04_co_so_du_lieu/sqlite_schema.sql', '''
-- Schema SQLite phiên bản 2 hiện tại; tham khảo lib/local/local_database.dart.
-- Đây là schema trống để giải trình, không phải dữ liệu từ điện thoại.
CREATE TABLE survey_drafts (
    member_id INTEGER NOT NULL,
    survey_id INTEGER NOT NULL,
    answers_json TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY(member_id, survey_id)
);
CREATE TABLE response_drafts (
    member_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    campaign_id INTEGER NOT NULL,
    payload_json TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY(member_id, item_id)
);
''')
for name in ['001_initial.sql', '002_member_management.sql', '003_first_admin.sql', '004_surveys_campaigns.sql', '005_category_images.sql']:
    target = ROOT / '04_co_so_du_lieu/sql_server' / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(DOAN / 'cuoiki/SurveyApi/Database' / name, target)

write('05_kiem_thu/ket_qua_va_cach_trinh_bay.md', '''
# Kết quả kiểm thử và cách trình bày

| Hình thức | Kết quả đã có | Nguồn và giới hạn |
| --- | --- | --- |
| Kiểm thử API | 134 lượt đạt | api-check-latest.log; script full_api_check.ps1 tạo và dọn dữ liệu tạm |
| Flutter tự động | 10 kiểm thử đạt | Bộ test trong survey_app/test; kết quả phiên kiểm tra gần nhất, chưa có log đầy đủ riêng trong thư mục này |
| Phân tích Dart | Không có vấn đề | flutter analyze trong phiên kiểm tra gần nhất |
| Build API | 0 lỗi, 0 warning | dotnet build trong phiên kiểm tra gần nhất |
| Build release | Thành công, khoảng 51 MB | apk-release-build.log |
| SQLite native trên Honor | 6 kiểm tra đạt | android-sqlite-result.json và device-check.png; đây là đợt kiểm tra kỹ thuật trước, không cộng vào 10 kiểm thử Flutter |
| Cài cập nhật release | Thành công, giữ phiên cục bộ | Minh chứng mở trang chủ trong tham_khao_cu; ảnh chụp lúc đang tải, không chứng minh tải dữ liệu thành công |
| Sử dụng Wi-Fi sau khi rút USB | Người dùng xác nhận ổn | Xác nhận thủ công trong phiên làm việc; cần ảnh minh chứng bản cuối nếu đưa vào báo cáo |

Các lượt API gồm phân quyền Member/Admin, danh mục/mẫu, ảnh mới/cũ, dọn file khi thất bại, tìm kiếm và phân trang, lọc ngày theo giờ Việt Nam, kế hoạch, checkout đồng thời, phản hồi đồng thời, thống kê, đổi mật khẩu, khóa tài khoản và đăng xuất. Không gọi 134 lượt là 134 màn hình hoặc khẳng định đã tự động kiểm thử toàn bộ trải nghiệm trên điện thoại.

Điền bảng kiem_thu_thuc_te.csv sau khi thao tác từng ca. Chưa điền sẵn Đạt cho các ca chưa có minh chứng riêng. Có thể ghi ngày, thiết bị và tên ảnh ở cột cuối.

Muốn chạy lại các kiểm thử: xem mã nguồn tests/full_api_check.ps1 và README của cuoiki. Script cần API kiểm thử riêng cổng 5081. Không chạy bừa trên database thật của doanh nghiệp; bộ tài nguyên không tự chạy các kiểm thử hoặc thay đổi database.
''')
cases = [
 ('TC01','Tài khoản','Đăng ký, đăng nhập đúng/sai','Tạo Member; từ chối thông tin sai'),
 ('TC02','Phân quyền','Member thử chức năng Admin','Giao diện ẩn; API từ chối thao tác quản trị'),
 ('TC03','Thành viên','Admin đổi role hoặc khóa tài khoản khác','Token cũ bị từ chối; đăng nhập lại theo quyền mới hoặc bị chặn khi khóa'),
 ('TC04','Danh mục','Thêm danh mục và ảnh, sửa mô tả, thay/bỏ ảnh','Hiển thị đúng; thay ảnh xóa file cũ, sửa mô tả giữ ảnh'),
 ('TC05','Danh mục','Xóa danh mục có mẫu','Bị chặn, dữ liệu và ảnh giữ nguyên'),
 ('TC06','Danh mục','Thay ảnh và lưu tên danh mục trùng','Báo trùng tên, ảnh cũ còn, ảnh mới không thành file thừa'),
 ('TC07','Mẫu','Thêm mẫu với bốn loại câu hỏi và ảnh','Tạo thành công; câu hỏi và ảnh hiển thị đúng'),
 ('TC08','Mẫu','Sửa/xóa mẫu đã nằm trong chiến dịch','Bị chặn để giữ lịch sử'),
 ('TC09','Danh sách','Tìm/lọc danh mục, chuyển trang và xem mẫu liên quan','Kết quả đúng, phân trang giữ điều kiện và không chứa chính mẫu đang xem'),
 ('TC10','Kế hoạch','Thêm trùng mẫu, sửa chỉ tiêu, xóa mẫu','Không trùng dòng; badge đếm số mẫu; mục tiêu hợp lệ'),
 ('TC11','Chiến dịch','Tạo chiến dịch từ kế hoạch','Có chi tiết đúng, kế hoạch được làm trống'),
 ('TC12','Trạng thái','Admin mở/đóng; Member thử đổi trạng thái','Chỉ Admin được đổi theo luồng hợp lệ'),
 ('TC13','Phản hồi','Bỏ câu bắt buộc, trả lời hợp lệ, thử gửi lần hai','Chặn thiếu/sai và gửi trùng; nhận phản hồi hợp lệ'),
 ('TC14','Nháp','Lưu nháp, tắt mạng, đóng/mở app rồi sửa nháp','Nháp đã lưu còn và tiếp tục sửa được'),
 ('TC15','Nháp','Gửi khi mất mạng, có mạng rồi gửi lại','Không báo thành công sai; giữ nháp; gửi thành công thì xóa nháp tương ứng'),
 ('TC16','Kết quả','Chủ chiến dịch/Admin xem thống kê; người tham gia khác thử xem','Thống kê đúng, người không có quyền bị chặn'),
 ('TC17','Không dây','Rút USB, mở app release, tải danh sách và gửi phản hồi qua Wi-Fi','Hoạt động khi máy chủ vẫn chạy và hai thiết bị cùng mạng'),
 ('TC18','Giao diện','Xoay ngang và mở bàn phím tại tìm kiếm, biểu mẫu và kết nối','Cuộn được, không tràn bố cục'),
 ('TC19','Đăng xuất','Đăng xuất khi có nháp thử','Có xác nhận; xóa phiên và nháp của đúng tài khoản'),
]
with (ROOT / '05_kiem_thu/kiem_thu_thuc_te.csv').open('w', newline='', encoding='utf-8-sig') as f:
    w=csv.writer(f); w.writerow(['Mã','Nhóm','Thao tác','Kết quả mong đợi','Kết quả thực tế','Trạng thái','Ngày thiết bị và minh chứng'])
    for case in cases: w.writerow([*case,'','Chưa ghi nhận riêng',''])
for src, dst in [
 (DOAN/'cuoiki/tests/api-check-latest.log', ROOT/'05_kiem_thu/api-check-latest.log'),
 (DOAN/'cuoiki/survey_app/apk-release-build.log', ROOT/'05_kiem_thu/apk-release-build.log'),
 (DOAN/'docs/evidence/android-sqlite-result.json', ROOT/'05_kiem_thu/android-sqlite-result.json'),
 (DOAN/'docs/evidence/device-check.png', ROOT/'06_anh_minh_chung/kiem_thu_ky_thuat/device-check.png'),
 (DOAN/'docs/evidence/survey-release-check.png', ROOT/'06_anh_minh_chung/tham_khao_cu/survey-release-check.png'),
]:
    if src.exists(): dst.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(src,dst)

shots = [
 ('01_tai_khoan','H01_dang_nhap.png','Màn hình đăng nhập ứng dụng khảo sát'),
 ('01_tai_khoan','H02_dang_ky.png','Đăng ký tài khoản Member'),
 ('01_tai_khoan','H03_doi_mat_khau.png','Đổi mật khẩu tài khoản'),
 ('02_quan_tri','H04_thanh_vien_vai_tro.png','Admin quản lý thành viên và phân quyền'),
 ('02_quan_tri','H05_danh_muc_co_anh.png','Danh mục khảo sát có ảnh đại diện'),
 ('02_quan_tri','H06_them_sua_danh_muc.png','Biểu mẫu chọn và thay ảnh danh mục'),
 ('03_mau_khao_sat','H07_trang_chu.png','Danh sách mẫu và bộ lọc danh mục'),
 ('03_mau_khao_sat','H08_them_mau_cau_hoi.png','Admin tạo mẫu với các loại câu hỏi'),
 ('03_mau_khao_sat','H09_chi_tiet_lien_quan.png','Chi tiết và mẫu khảo sát liên quan'),
 ('04_chien_dich','H10_ke_hoach.png','Kế hoạch khảo sát và chỉ tiêu phản hồi'),
 ('04_chien_dich','H11_chi_tiet_chien_dich.png','Chi tiết chiến dịch và các mẫu triển khai'),
 ('04_chien_dich','H12_tim_kiem_loc_ngay.png','Tìm chiến dịch và lọc ngày tạo'),
 ('04_chien_dich','H13_duyet_mo_dong.png','Admin quản lý trạng thái chiến dịch'),
 ('05_phan_hoi_nhap','H14_tra_loi.png','Người dùng trả lời khảo sát'),
 ('05_phan_hoi_nhap','H15_ban_nhap.png','Nháp lưu trên điện thoại'),
 ('05_phan_hoi_nhap','H16_mo_nhap_offline.png','Mở và sửa nháp khi không kết nối máy chủ'),
 ('05_phan_hoi_nhap','H17_thong_ke.png','Kết quả phản hồi và điểm đánh giá'),
 ('06_ket_noi','H18_ket_noi_wifi.png','Cấu hình và kiểm tra kết nối máy chủ qua Wi-Fi'),
 ('06_ket_noi','H19_app_khong_day.png','Ứng dụng release hoạt động sau khi rút USB'),
 ('07_rang_buoc','H20_chan_xoa_danh_muc.png','Không cho xóa danh mục còn mẫu khảo sát'),
 ('07_rang_buoc','H21_khoa_mau_da_dung.png','Mẫu đã triển khai bị khóa sửa để giữ lịch sử'),
]
lines=['# Danh sách ảnh cần chụp', '', 'Các dòng dưới là danh sách cần bổ sung, không phải ảnh đã có. Chụp từ bản app cuối với dữ liệu rõ nghĩa, tránh tên nhập thử vô nghĩa. Không chụp mật khẩu, token hoặc thông tin cá nhân không cần thiết.', '', '| Thư mục | Tên file đề nghị | Chú thích dùng trong Word |', '| --- | --- | --- |']
for folder,name,caption in shots:
    (ROOT/'06_anh_minh_chung'/folder).mkdir(parents=True,exist_ok=True)
    lines.append(f'| {folder} | {name} | {caption} |')
lines += ['', 'Mỗi ảnh nên kèm 1–3 câu mô tả thao tác, quyền đang dùng và kết quả. Có thể bỏ ảnh trùng hoặc gộp hai ảnh cùng nghiệp vụ; số Hxx là mã dự kiến, không phải số hình tự động của Word.', '', 'H19: một ảnh chụp màn hình không tự chứng minh đã rút USB; ghi rõ điều kiện kiểm tra và ngày thực hiện, có thể thêm ảnh chụp điện thoại hoạt động không cắm dây. Không cần giả lập hoặc tạo ảnh minh chứng thành công.', '', 'Ảnh device-check.png chỉ chứng minh lần kiểm thử SQLite kỹ thuật. Ảnh survey-release-check.png là ảnh cũ lúc danh sách đang tải, không dùng làm ảnh trang chủ hoàn thiện.']
write('06_anh_minh_chung/danh_sach_anh_can_chup.md', '\n'.join(lines))

write('07_huong_dan/cau_truc_ma_nguon.md', '''
# Cấu trúc mã nguồn dùng để giải trình

```text
DOAN/cu oiki  (đường dẫn thực tế: DOAN/cuoiki)
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
'''.replace('DOAN/cu oiki  (đường dẫn thực tế: DOAN/cuoiki)', 'DOAN/cuoiki'))
write('07_huong_dan/danh_sach_api.md', '''
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
''')
write('07_huong_dan/danh_sach_ho_so_nop.md', '''
# Danh sách hồ sơ nộp

- [ ] Báo cáo Word hoàn chỉnh theo mẫu trường, đúng thông tin sinh viên và giảng viên.
- [ ] Bảng đối chiếu có trạng thái ảnh danh mục đã hoàn thành và ghi rõ chức năng tương đương.
- [ ] Ảnh minh chứng chức năng từ bản app cuối, chú thích và số hình thống nhất.
- [ ] Sơ đồ kiến trúc, database và luồng nghiệp vụ khớp mã nguồn.
- [ ] Bảng kiểm thử thủ công có kết quả thực tế, không tự điền Đạt cho ca chưa kiểm tra.
- [ ] Mã nguồn DOAN/cuoiki gồm Flutter, API, script database và hướng dẫn chạy.
- [ ] APK release mới nhất tại survey_app/build/app/outputs/flutter-apk/app-release.apk.
- [ ] Hướng dẫn chạy trên máy mới, cấp Admin đầu tiên và cấu hình Wi-Fi.
- [ ] Kiểm tra không đưa .local-jwt-key, mật khẩu, token, debug keystore hoặc dữ liệu tài khoản thật vào báo cáo/phụ lục.
- [ ] Nếu giảng viên yêu cầu dữ liệu mẫu, chuẩn bị dữ liệu trình bày riêng, không tự xóa dữ liệu thật.

Chưa đóng gói bản nộp hoặc sao lưu database thật trong bước chuẩn bị tài nguyên này. Không cần sao chép thư mục build, .gradle-local hoặc cache vào mã nguồn nộp nếu không có yêu cầu riêng. Bộ tài nguyên không thay thế mã nguồn và APK.
''')
for src,name in [(DOAN/'cuoiki/README.md','huong_dan_chay_du_an.md'),(DOAN/'docs/app-completion-wifi.md','huong_dan_wifi_va_ban_release.md')]:
    content = src.read_text(encoding='utf-8-sig')
    content = content.replace('(../docs/', '(../../docs/')
    if name == 'huong_dan_wifi_va_ban_release.md':
        content = content.replace('Chưa xác nhận kết nối Wi-Fi vì API người dùng vẫn là phiên cũ chỉ lắng nghe localhost và quyền tường lửa cần Administrator.', 'Sau bước chuẩn bị máy chủ, người dùng đã xác nhận sử dụng qua Wi-Fi ổn; xác nhận này là kiểm tra thủ công, không phải kiểm thử tự động đường truyền.')
        content = content.replace('- Còn cần xác nhận trực tiếp trên điện thoại sau khi cấp quyền tường lửa và khởi động lại API mới; kết quả kiểm thử trên máy không chứng minh đường truyền Wi-Fi giữa hai thiết bị.', '- Người dùng đã xác nhận app sử dụng Wi-Fi ổn. Cần bổ sung ảnh minh chứng bản cuối cho báo cáo; không suy ra mọi ca kiểm thử thủ công đều đã đạt từ một xác nhận tổng quát.')
        content = content.replace('Phiên công cụ không có quyền Administrator nên chưa thêm được quy tắc này.', 'Khi cấu hình lần đầu, công cụ không có quyền Administrator để thêm quy tắc; bước này cần người dùng thực hiện nếu tường lửa chưa cho phép kết nối.')
    write('07_huong_dan/' + name, content)

print(f'Resources: {ROOT}')
print(f'Requirement rows: {len(rows)}')
