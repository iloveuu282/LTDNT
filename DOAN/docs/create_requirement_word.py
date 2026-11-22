from pathlib import Path
from copy import deepcopy
from docx import Document
from docx.shared import Cm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'Doi_chieu_yeu_cau_Flutter_khao_sat_doanh_nghiep.docx'
doc = Document()
sec = doc.sections[0]
sec.page_width, sec.page_height = Cm(29.7), Cm(21)
sec.top_margin = sec.bottom_margin = Cm(1.5)
sec.left_margin = sec.right_margin = Cm(1.6)
for name in ['Normal', 'Title', 'Heading 1', 'Heading 2']:
    style = doc.styles[name]
    style.font.name = 'Arial'
    style.font.color.rgb = RGBColor(0, 0, 0)
    style.paragraph_format.space_after = Pt(5)
    props = style.element.find(qn('w:pPr'))
    if props is not None:
        for border in list(props.findall(qn('w:pBdr'))): props.remove(border)
doc.styles['Normal'].font.size = Pt(10.5)
doc.styles['Title'].font.size = Pt(21)
doc.styles['Title'].paragraph_format.space_after = Pt(9)
doc.add_paragraph('Đối chiếu yêu cầu Flutter và tiến độ thực hiện', 'Title')
doc.add_paragraph('Đề tài  Xây dựng ứng dụng hỗ trợ khảo sát cho doanh nghiệp')
doc.add_paragraph('Cập nhật ngày 19 tháng 11 năm 2026. Bảng giữ các tiêu chí và mức điểm của yêu cầu, bổ sung cột trạng thái để theo dõi phần đã làm, phần tương đương và lý do chưa làm.')
doc.add_paragraph('Đã hoàn thành tương đương: chức năng đã được triển khai theo nghiệp vụ khảo sát; cần giải trình với giảng viên để được tính điểm. Trạng thái phản ánh mã nguồn hiện có, không đồng nghĩa đã được chấm điểm.')

table = doc.add_table(rows=1, cols=4)
table.alignment = WD_TABLE_ALIGNMENT.CENTER
table.autofit = False
widths = [8.1, 3.1, 2.4, 12.9]
for cell, width, label in zip(table.rows[0].cells, widths, ['Chức năng', 'Yêu cầu', 'Điểm', 'Trạng thái và ghi chú']):
    cell.width = Cm(width)
    cell.text = label
for col, width in zip(table.columns, widths): col.width = Cm(width)
repeat = OxmlElement('w:tblHeader')
table.rows[0]._tr.get_or_add_trPr().append(repeat)

def row(title, required, score, note, group=False):
    cells = table.add_row().cells
    for c, width, value in zip(cells, widths, [title, required, score, note]):
        c.width = Cm(width)
        c.text = value
    if group:
        for c in cells:
            shade = OxmlElement('w:shd'); shade.set(qn('w:fill'), 'E7EEF4'); c._tc.get_or_add_tcPr().append(shade)
            for p in c.paragraphs:
                p.paragraph_format.keep_with_next = False
                for r in p.runs: r.bold = True

def done(title, score, note, equivalent=False, required='Bắt buộc'):
    state = 'Đã hoàn thành tương đương. ' if equivalent else 'Đã hoàn thành. '
    row(title, required, score, state + note)

def pending(title, score, reason): row(title, 'Điểm cộng', score, 'Chưa làm. ' + reason)

row('Công nghệ bắt buộc', 'Bắt buộc', 'Điều kiện', 'Đã đáp ứng các công nghệ yêu cầu.', True)
done('Flutter sử dụng ngôn ngữ Dart', '—', 'Ứng dụng điện thoại trong cuoiki/survey_app.')
done('SQLite lưu trữ trên điện thoại', '—', 'Lưu, đọc, sửa và xóa nháp trả lời theo tài khoản; giữ nháp khi mất kết nối.')
done('REST API C# ASP.NET Core 10 và SQL Server', '—', 'SurveyApi dùng net10.0; SQL Server lưu tài khoản, danh mục, mẫu khảo sát, chiến dịch và phản hồi.')
row('Nhóm xác thực người dùng', 'Nhóm bắt buộc', '2.25 + 0.75 API', 'Đã có các chức năng bắt buộc và xác thực qua API.', True)
done('Đăng ký người dùng', '0.25', 'Đăng ký qua API; tài khoản mới mặc định Member.')
done('Đăng nhập', '0.25', 'Đăng nhập bằng email và mật khẩu; API cấp JWT.')
done('Đổi mật khẩu', '0.25', 'Kiểm tra mật khẩu hiện tại; thu hồi token cũ sau khi đổi thành công.')
done('Quản lý member', '0.25', 'Admin xem danh sách, sửa họ tên, khóa/mở và xóa tài khoản chưa có dữ liệu liên quan.')
done('Quản lý role người dùng', '0.5', 'Admin gán vai trò Admin hoặc Member. Hai vai trò cố định; không tạo role tùy ý.')
done('Chức năng thoát logout', '0.25', 'Đăng xuất và xóa dữ liệu phiên cục bộ; gọi API thu hồi token khi có kết nối.')
done('Phân quyền Member và Admin', '0.5', 'Ẩn chức năng quản trị với Member; API kiểm tra quyền cho các thao tác quản trị.')
pending('Xác thực người dùng qua email', '0.5', 'Để sau vì cần dịch vụ gửi email, mã xác thực, thời hạn và xử lý gửi lại; mức trung bình.')
pending('Quên mật khẩu', '0.5', 'Để sau vì cần kênh email và luồng khôi phục an toàn, mã dùng một lần có hạn; mức trung bình.')
pending('Đăng nhập bằng Gmail Google, Facebook, Zalo', '3 × 0.5', 'Để sau vì cần đăng ký ứng dụng với từng nhà cung cấp, OAuth và cấu hình Android; mức trung bình đến khó.')

row('Quản lý danh mục dành cho Admin', 'Nhóm bắt buộc', '1.25 + 0.5 API', 'Danh mục dùng để phân loại mẫu khảo sát; các thao tác qua API.', True)
done('Hiển thị danh mục', '0.25', 'Danh sách danh mục khảo sát.', True)
done('Thêm danh mục', '0.25', 'Admin thêm danh mục khảo sát.', True)
done('Xóa danh mục', '0.25', 'Admin xóa danh mục trống.', True)
done('Kiểm tra danh mục có sản phẩm trước khi xóa', '0.25', 'Chặn xóa danh mục còn chứa mẫu khảo sát.', True)
done('Sửa danh mục', '0.25', 'Admin sửa tên và mô tả danh mục.', True)
pending('Upload ảnh danh mục khi thêm, xóa và sửa', '0.75', 'Để sau ở mức trung bình: cần bổ sung cột dữ liệu, upload, thay ảnh và dọn ảnh cũ. Ảnh mẫu khảo sát đã có; ảnh danh mục chưa có.')

row('Quản lý sản phẩm theo từng danh mục', 'Nhóm bắt buộc', '2 + 0.75 API', 'Sản phẩm được quy đổi thành mẫu khảo sát; có upload ảnh và phân trang qua API.', True)
done('Hiển thị sản phẩm có phân trang', '0.5', 'Danh sách mẫu khảo sát theo danh mục, 10 mẫu mỗi trang.', True)
done('Thêm sản phẩm có upload hình ảnh', '0.5', 'Admin thêm mẫu, câu hỏi và ảnh bắt buộc; kiểm tra định dạng PNG/JPEG và dung lượng.', True)
done('Xóa sản phẩm và xóa ảnh kèm theo', '0.5', 'Xóa mẫu chưa dùng và ảnh của mẫu đó.', True)
done('Sửa sản phẩm và xóa ảnh cũ khi thay ảnh mới', '0.5', 'Sửa mẫu chưa triển khai; thay ảnh thì xóa ảnh cũ. Mẫu đã nằm trong chiến dịch bị khóa sửa.', True)
done('Kiểm tra sản phẩm có trong đơn hàng trước khi xóa', '0.5', 'Chặn xóa mẫu đã nằm trong chiến dịch để bảo toàn lịch sử và phản hồi.', True, 'Điểm cộng')

row('Hiển thị sản phẩm trên trang chủ', 'Nhóm bắt buộc', '1.75 + 0.5 API', 'Trang chủ hiển thị danh mục và mẫu khảo sát qua API. Giữ nguyên tổng nhóm theo đề bài.', True)
done('Hiển thị danh mục sản phẩm', '0.25', 'Hiển thị danh mục khảo sát để chọn lọc.', True)
done('Hiển thị sản phẩm mới nhất có phân trang', '0.5', 'Mẫu mới nhất trước, 10 mẫu mỗi trang.', True)
done('Hiển thị sản phẩm theo danh mục', '0.25; +0.25 phân trang', 'Lọc mẫu theo danh mục và phân trang; đã có phần phân trang cộng thêm.', True)
done('Tìm kiếm sản phẩm', '0.25; +0.25 phân trang', 'Tìm theo tên mẫu khảo sát và phân trang; đã có phần phân trang cộng thêm.', True)
done('Hiển thị chi tiết sản phẩm', '0.25', 'Chi tiết tên mẫu, danh mục, mô tả, ảnh và nội dung câu hỏi.', True)
done('Hiển thị sản phẩm liên quan', '0.25; +0.25 phân trang', 'Các mẫu khác cùng danh mục, loại chính mẫu đang xem, có phân trang 10 mẫu mỗi trang.', True, 'Điểm cộng')

row('Quản lý giỏ hàng', 'Nhóm bắt buộc', '2.5 + 1 API', 'Giỏ hàng quy đổi thành kế hoạch khảo sát; đơn hàng quy đổi thành chiến dịch.', True)
done('Đặt button thêm giỏ hàng', '0.25', 'Có nút Thêm vào kế hoạch trong chi tiết mẫu.', True)
done('Thêm sản phẩm vào giỏ hàng', '0.25', 'Thêm mẫu vào kế hoạch; một mẫu không bị thêm trùng.', True)
done('Hiển thị số lượng sản phẩm trên icon giỏ hàng', '0.25', 'Badge hiển thị số mẫu khác nhau trong kế hoạch, không phải tổng số phản hồi mục tiêu.', True)
done('Hiển thị giỏ hàng', '0.25', 'Màn hình kế hoạch hiển thị mẫu và số phản hồi mục tiêu.', True)
done('Cập nhật số lượng trên giỏ hàng', '0.5', 'Thay số phản hồi mục tiêu của từng mẫu trong kế hoạch.', True)
done('Xóa sản phẩm trên giỏ hàng', '0.25', 'Xóa mẫu khỏi kế hoạch của tài khoản hiện tại.', True)
done('Chức năng đặt hàng checkout', '0.5', 'Xác nhận tạo chiến dịch từ kế hoạch, lưu các mẫu và mục tiêu rồi làm trống kế hoạch; chống tạo trùng khi gửi lại.', True)
done('Hiển thị chi tiết đơn hàng', '0.25', 'Chi tiết chiến dịch gồm các mẫu, mục tiêu, số phản hồi và trạng thái.', True)
done('Tìm kiếm đơn hàng', '0.25', 'Member tìm chiến dịch của mình theo tên hoặc mã, có phân trang.', True, 'Điểm cộng')
pending('Thanh toán online VNPayment, VietQR', '2 × 0.5', 'Không phù hợp phạm vi hiện tại: ứng dụng tổ chức khảo sát, không bán hàng hoặc thu tiền. Chỉ cân nhắc khi có nghiệp vụ bán gói dịch vụ khảo sát; tích hợp thanh toán cũng có độ phức tạp cao hơn.')

row('Quản lý đơn hàng dành cho Admin', 'Nhóm bắt buộc', '0.75 + 0.25 API', 'Admin quản lý chiến dịch khảo sát qua API.', True)
done('Hiển thị danh sách đơn hàng', '0.25', 'Admin xem toàn bộ chiến dịch có phân trang.', True)
done('Cập nhật trạng thái đơn hàng', '0.5', 'Admin duyệt mở hoặc hủy chiến dịch đang chờ; đóng chiến dịch đang mở. Member không được đổi trạng thái.', True)
done('Tìm kiếm đơn hàng', '0.25', 'Admin tìm chiến dịch theo tên hoặc mã, có phân trang.', True, 'Điểm cộng')
done('Lọc đơn hàng theo ngày', '0.25', 'Lọc ngày tạo chiến dịch theo giờ Việt Nam; có thể kết hợp từ khóa và phân trang.', True, 'Điểm cộng')

for i, tr in enumerate(table.rows):
    props = tr._tr.get_or_add_trPr()
    props.append(OxmlElement('w:cantSplit'))
    for j, cell in enumerate(tr.cells):
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        tcpr = cell._tc.get_or_add_tcPr()
        borders = OxmlElement('w:tcBorders')
        for edge in ['top', 'left', 'bottom', 'right']:
            e = OxmlElement('w:' + edge)
            for key, value in [('val', 'single'), ('sz', '4'), ('color', 'D9D9D9')]: e.set(qn('w:' + key), value)
            borders.append(e)
        tcpr.append(borders)
        margins = OxmlElement('w:tcMar')
        for edge, value in [('top', '80'), ('bottom', '80'), ('left', '100'), ('right', '100')]:
            e = OxmlElement('w:' + edge); e.set(qn('w:w'), value); e.set(qn('w:type'), 'dxa'); margins.append(e)
        tcpr.append(margins)
        for p in cell.paragraphs:
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.05
            if j in [1, 2]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        if i == 0:
            shade = OxmlElement('w:shd'); shade.set(qn('w:fill'), 'DBE5EF'); tcpr.append(shade)
            for p in cell.paragraphs:
                p.paragraph_format.keep_with_next = True
                for r in p.runs: r.bold = True

# Chia tại các mốc ổn định để Word luôn hiển thị đầu bảng trên mỗi trang.
for n, (start, end) in enumerate([(1, 13), (13, 29), (29, 44), (44, 52)]):
    part = deepcopy(table._tbl)
    for index, tr in enumerate(list(part.findall(qn('w:tr')))):
        if index != 0 and not start <= index < end: part.remove(tr)
    for header in part.findall('.//' + qn('w:tblHeader')): header.getparent().remove(header)
    table._tbl.addprevious(part)
    if n < 3:
        paragraph = OxmlElement('w:p')
        ppr = OxmlElement('w:pPr')
        spacing = OxmlElement('w:spacing'); spacing.set(qn('w:after'), '0'); spacing.set(qn('w:before'), '0'); spacing.set(qn('w:line'), '20'); spacing.set(qn('w:lineRule'), 'exact'); ppr.append(spacing)
        paragraph.append(ppr)
        run = OxmlElement('w:r'); br = OxmlElement('w:br'); br.set(qn('w:type'), 'page'); run.append(br); paragraph.append(run)
        table._tbl.addprevious(paragraph)
table._tbl.getparent().remove(table._tbl)
doc.add_paragraph('Lưu ý khi đối chiếu', 'Heading 1')
doc.add_paragraph('Sinh viên sử dụng công nghệ khác với Flutter Dart, SQLite và REST API C# .NET Core 10 cùng SQL Server sẽ không được tính điểm theo yêu cầu. Ngoài các chức năng trong bảng, sinh viên phải giải trình để được tính điểm chức năng tương đương.')
doc.add_paragraph('Bảng giữ nguyên điểm từng tiêu chí và tổng nhóm từ yêu cầu, không tự cộng thành điểm cuối cùng. Riêng nhóm trang chủ: các dòng bắt buộc cộng được 1.5 điểm, trong khi tổng nhóm đề bài ghi 1.75 điểm; cần hỏi giảng viên cách tính. Phân trang theo danh mục, tìm kiếm và mẫu liên quan được ghi riêng như phần cộng thêm trong đề.')
doc.add_paragraph('Các chức năng phù hợp đề tài ngoài bảng: tạo và quản lý câu hỏi, tham gia khảo sát, kiểm tra câu trả lời, thống kê kết quả, lưu nháp SQLite và gửi lại khi có kết nối. Các phần này cần giải trình riêng nếu đề nghị tính điểm.')
doc.add_paragraph('Minh chứng kỹ thuật hiện có: API build thành công; 115 lượt kiểm tra API và 7 kiểm thử Flutter đạt; flutter analyze không báo vấn đề; APK debug build thành công. Các chức năng mới vẫn cần xác nhận trải nghiệm thực tế trên điện thoại.')
footer = sec.footer.paragraphs[0]
footer.alignment = WD_ALIGN_PARAGRAPH.RIGHT
footer.add_run('Trang ')
fld = OxmlElement('w:fldSimple'); fld.set(qn('w:instr'), 'PAGE'); footer._p.append(fld)
doc.core_properties.title = 'Đối chiếu yêu cầu Flutter và tiến độ ứng dụng khảo sát doanh nghiệp'
doc.core_properties.author = ''
doc.save(OUT)
print(OUT)
print('Table rows:', len(table.rows))
