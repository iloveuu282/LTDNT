from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math

OUT = Path(__file__).resolve().parents[1] / 'tai_nguyen_bao_cao/03_so_do'
OUT.mkdir(parents=True, exist_ok=True)
FONT = 'C:/Windows/Fonts/arial.ttf'
BOLD = 'C:/Windows/Fonts/arialbd.ttf'
TEAL = '#00695C'
INK = '#172B35'
LINE = '#48636D'

def font(size, bold=False): return ImageFont.truetype(BOLD if bold else FONT, size)

def canvas(w, h, title, subtitle):
    im = Image.new('RGB', (w, h), 'white')
    d = ImageDraw.Draw(im)
    d.text((70, 35), title, font=font(44, True), fill='black')
    d.text((70, 95), subtitle, font=font(27), fill=INK)
    return im, d

def wrap(d, text, f, width):
    lines=[]
    for paragraph in text.split('\n'):
        current=''
        for word in paragraph.split():
            candidate=(current+' '+word).strip()
            if current and d.textlength(candidate,font=f)>width: lines.append(current); current=word
            else: current=candidate
        lines.append(current)
    return lines

def label(d, xy, text, size=27, fill=INK, background=True):
    f=font(size)
    box=d.textbbox((0,0),text,font=f)
    x,y=xy; w=box[2]-box[0]; h=box[3]-box[1]
    if background: d.rounded_rectangle((x-w/2-9,y-7,x+w/2+9,y+h+7),radius=6,fill='white')
    d.text((x-w/2,y-box[1]),text,font=f,fill=fill)

def arrow(d, pts, text=None, label_xy=None, color=LINE, size=26):
    d.line(pts, fill=color, width=5, joint='curve')
    (x0,y0),(x1,y1)=pts[-2:]
    a=math.atan2(y1-y0,x1-x0)
    d.polygon([(x1,y1),(x1-19*math.cos(a-.45),y1-19*math.sin(a-.45)),(x1-19*math.cos(a+.45),y1-19*math.sin(a+.45))],fill=color)
    if text: label(d,label_xy or ((x0+x1)/2,(y0+y1)/2-16),text,size)

def box(d, rect, title, body, fill='#EAF5F2', title_size=35, size=29):
    x,y,r,b=rect
    d.rounded_rectangle(rect,radius=20,fill=fill,outline=TEAL,width=3)
    d.text((x+26,y+21),title,font=font(title_size,True),fill='black')
    yy=y+82
    for line in wrap(d,body,font(size),r-x-52):
        d.text((x+26,yy),line,font=font(size),fill=INK); yy+=size+12
    assert yy <= b+12, (title,yy,b)

def save(im, name): im.save(OUT/name,dpi=(300,300))

im,d=canvas(2700,1450,'Kiến trúc ứng dụng khảo sát doanh nghiệp','Flutter và SQLite trên điện thoại kết nối REST API C# .NET 10 và SQL Server trên máy chủ')
box(d,(100,260,790,710),'Điện thoại Android','Flutter và ngôn ngữ Dart\nPages → Repositories → ApiService\nNhập câu hỏi, kế hoạch và phản hồi\nBản release mở từ icon ứng dụng')
box(d,(1070,260,1760,710),'REST API C# .NET 10','Controller kiểm tra quyền và đầu vào\nSiteProvider và Repository Dapper\nJWT, BCrypt và transaction\nXử lý upload và xóa ảnh')
box(d,(2040,260,2600,710),'SQL Server','Dữ liệu nghiệp vụ tập trung\nTài khoản, mẫu, chiến dịch\nKế hoạch và phản hồi\nKhóa ngoại và ràng buộc')
arrow(d,[(790,410),(1070,410)],'Yêu cầu JSON', (930,360))
arrow(d,[(1070,590),(790,590)],'Kết quả JSON', (930,620))
arrow(d,[(1760,410),(2040,410)],'SQL Dapper',(1900,360))
arrow(d,[(2040,590),(1760,590)],'Dữ liệu',(1900,620))
box(d,(100,930,790,1260),'SQLite và Secure Storage','SQLite: nháp trả lời theo tài khoản\nSecure Storage: token, hồ sơ, URL\nKhông tự gửi nháp nền',size=29)
arrow(d,[(400,710),(400,930)],'Lưu và đọc cục bộ',(400,815))
box(d,(1070,930,1760,1260),'File ảnh trên máy chủ','wwwroot/uploads\nẢnh danh mục và mẫu khảo sát\nSQL Server chỉ lưu đường dẫn',size=29)
arrow(d,[(1420,710),(1420,930)],'Upload và tải ảnh',(1420,815))
box(d,(2040,930,2600,1260),'Kết nối mạng','Wi-Fi cùng mạng nội bộ\nMáy tính vẫn chạy API\nHTTPS khi triển khai Internet',size=28)
label(d,(1360,1360),'Mất mạng: chỉ đọc và sửa nháp đã lưu; gửi phản hồi cần kết nối trở lại.',29)
save(im,'01_kien_truc_he_thong.png')

im,d=canvas(3100,1950,'Quan hệ dữ liệu SQL Server','Mũi tên đi từ bảng cha đến bảng con   1 → N   PK là khóa chính   FK là khóa ngoại   UQ là duy nhất')
nodes={
 'Roles':((100,180,950,570),'RoleId PK\nRoleName UQ'),
 'Categories':((1125,180,1975,570),'CategoryId PK\nCategoryName UQ\nDescription\nImagePath NULL'),
 'Campaigns':((2150,180,3000,570),'CampaignId PK\nMemberId FK → Members\nTitle, Status, CreatedAt\nRequestId\nUQ (MemberId, RequestId)'),
 'Members':((100,750,950,1170),'MemberId PK\nRoleId FK → Roles\nFullName, Email UQ\nPasswordHash, CreatedAt\nIsActive, TokenVersion'),
 'Surveys':((1125,750,1975,1170),'SurveyId PK\nCategoryId FK → Categories\nTitle, Description, ImagePath\nQuestionsJson, CreatedAt'),
 'CampaignItems':((2150,750,3000,1170),'ItemId PK\nCampaignId FK → Campaigns\nSurveyId FK → Surveys\nTargetCount\nUQ (CampaignId, SurveyId)'),
 'PlanItems':((600,1390,1450,1740),'PK (MemberId, SurveyId)\nMemberId FK → Members\nSurveyId FK → Surveys\nTargetCount'),
 'Responses':((2150,1390,3000,1740),'ResponseId PK\nItemId FK → CampaignItems\nMemberId FK → Members\nSubmissionId UQ, AnswersJson\nCreatedAt; UQ (ItemId, MemberId)'),
}
for name,(rect,body) in nodes.items(): box(d,rect,name,body,size=28,title_size=36)
arrow(d,[(525,570),(525,750)],'1 → N',(525,645))
arrow(d,[(1550,570),(1550,750)],'1 → N',(1550,645))
arrow(d,[(2575,570),(2575,750)],'1 → N',(2575,645))
arrow(d,[(950,950),(1030,950),(1030,675),(2460,675),(2460,570)],'Chủ chiến dịch 1 → N',(2000,690),size=25)
arrow(d,[(1975,950),(2150,950)],'1 → N',(2060,910))
arrow(d,[(2575,1170),(2575,1390)],'1 → N',(2575,1260))
arrow(d,[(350,1170),(350,1250),(950,1250),(950,1390)],'Thành viên 1 → N',(650,1210),size=25)
arrow(d,[(1600,1170),(1600,1285),(1300,1285),(1300,1390)],'Mẫu 1 → N',(1540,1310),size=25)
arrow(d,[(100,1040),(45,1040),(45,1835),(2575,1835),(2575,1740)],'Người trả lời 1 → N',(1900,1800),size=26)
label(d,(1560,1900),'Câu hỏi và câu trả lời lưu JSON; ảnh lưu file, không lưu dữ liệu nhị phân trong các bảng.',27)
save(im,'02_erd_sql_server.png')

im,d=canvas(2700,1460,'Luồng triển khai khảo sát','Admin quản lý nội dung và duyệt trạng thái   Người dùng chuẩn bị kế hoạch và tham gia khảo sát')
box(d,(100,250,800,570),'1   Chuẩn bị mẫu','Admin tạo danh mục, ảnh\nvà câu hỏi khảo sát')
box(d,(1000,250,1700,570),'2   Lập kế hoạch','Chọn các mẫu cần triển khai\nNhập số phản hồi mục tiêu')
box(d,(1900,250,2600,570),'3   Tạo chiến dịch','Xác nhận kế hoạch\nTrạng thái ban đầu: Pending')
box(d,(1900,850,2600,1190),'4   Mở chiến dịch','Admin chuyển Pending → Active\nCó thể hủy khi còn Pending')
box(d,(1000,850,1700,1190),'5   Thu thập phản hồi','Người dùng trả lời, lưu nháp\nGửi khi kết nối và còn chỉ tiêu')
box(d,(100,850,800,1190),'6   Kết quả và kết thúc','Chủ chiến dịch/Admin xem kết quả\nAdmin đóng: Active → Closed')
arrow(d,[(800,410),(1000,410)])
arrow(d,[(1700,410),(1900,410)])
arrow(d,[(2250,570),(2250,850)])
arrow(d,[(1900,1020),(1700,1020)])
arrow(d,[(1000,1020),(800,1020)])
label(d,(1350,1320),'Một tài khoản chỉ gửi một lần cho mỗi mẫu trong một chiến dịch.',31)
save(im,'03_luong_nghiep_vu.png')

im,d=canvas(2500,1180,'Các nhóm chức năng theo vai trò','Cả Member và Admin đều là tài khoản đã xác thực; server kiểm tra quyền trên từng yêu cầu')
box(d,(100,230,740,600),'Member','Xem và tìm mẫu khảo sát\nKế hoạch và chiến dịch của mình\nTham gia khảo sát, lưu nháp\nXem kết quả chiến dịch sở hữu',size=29)
box(d,(1760,230,2400,600),'Admin','Quản lý thành viên và vai trò\nQuản lý danh mục, ảnh và mẫu\nXem tất cả chiến dịch, kết quả\nDuyệt mở, hủy hoặc đóng',size=29)
box(d,(920,740,1580,1040),'Chức năng dùng chung','Đổi mật khẩu và đăng xuất\nKết nối máy chủ, lưu nháp riêng\nXem mẫu, tham gia và lập kế hoạch',size=28)
arrow(d,[(740,420),(830,420),(830,870),(920,870)])
arrow(d,[(1760,420),(1670,420),(1670,870),(1580,870)])
save(im,'04_nhom_chuc_nang_theo_vai_tro.png')

sources={
 '01_kien_truc_he_thong.mmd':'''flowchart LR
    APP[Flutter Dart trên Android] -->|REST JSON và upload ảnh| API[C# ASP.NET Core 10]
    API -->|Dapper và SQL| DB[(SQL Server)]
    APP --> SQLITE[(SQLite nháp cục bộ)]
    APP --> SECURE[Secure Storage token hồ sơ URL]
    API --> FILE[wwwroot/uploads]
''',
 '02_erd_sql_server.mmd':'''erDiagram
    Roles ||--o{ Members : RoleId
    Members ||--o{ PlanItems : MemberId
    Members ||--o{ Campaigns : MemberId
    Members ||--o{ Responses : MemberId
    Categories ||--o{ Surveys : CategoryId
    Surveys ||--o{ PlanItems : SurveyId
    Surveys ||--o{ CampaignItems : SurveyId
    Campaigns ||--o{ CampaignItems : CampaignId
    CampaignItems ||--o{ Responses : ItemId
    Roles { int RoleId PK }
    Members { int MemberId PK
        int RoleId FK }
    Categories { int CategoryId PK }
    Surveys { int SurveyId PK
        int CategoryId FK }
    PlanItems { int MemberId PK,FK
        int SurveyId PK,FK }
    Campaigns { int CampaignId PK
        int MemberId FK }
    CampaignItems { int ItemId PK
        int CampaignId FK
        int SurveyId FK }
    Responses { int ResponseId PK
        int ItemId FK
        int MemberId FK }
''',
 '03_luong_nghiep_vu.mmd':'''flowchart TD
    A[Admin chuẩn bị danh mục mẫu và câu hỏi] --> B[Người dùng lập kế hoạch và chỉ tiêu]
    B --> C[Tạo chiến dịch Pending]
    C --> D[Admin mở Active]
    C --> E[Admin hủy Cancelled]
    D --> F[Người dùng trả lời hoặc lưu nháp SQLite]
    F --> G[Gửi phản hồi khi có kết nối]
    G --> H[Chủ chiến dịch hoặc Admin xem kết quả]
    D --> I[Admin đóng Closed]
''',
 '04_nhom_chuc_nang_theo_vai_tro.mmd':'''flowchart LR
    M[Member] --> A[Xem mẫu và lập kế hoạch]
    M --> B[Tạo và xem chiến dịch của mình]
    M --> C[Tham gia khảo sát và lưu nháp]
    M --> D[Xem kết quả chiến dịch sở hữu]
    AD[Admin] --> E[Quản lý thành viên và vai trò]
    AD --> F[Quản lý danh mục mẫu và ảnh]
    AD --> G[Xem tất cả chiến dịch và kết quả]
    AD --> H[Duyệt mở hủy đóng chiến dịch]
    AD --> A
    AD --> C
'''
}
for name,content in sources.items(): (OUT/name).write_text(content,encoding='utf-8')
(OUT/'README.md').write_text('''# Sơ đồ để chèn vào Word

Chèn các file PNG, không chụp ảnh màn hình mã Mermaid. Hình 02 khá rộng, nên dùng trang ngang hoặc cả chiều rộng trang để đọc rõ trường dữ liệu. Các ảnh có thông tin 300 DPI và có thể thu nhỏ khi chèn.

File .mmd là nguồn Mermaid để chỉnh sửa. PNG được vẽ độc lập từ cùng mô hình nghiệp vụ nên bố trí không nhất thiết giống Mermaid. Hình 04 là sơ đồ nhóm chức năng theo vai trò, không phải ký pháp UML use case đầy đủ. Nếu giảng viên yêu cầu đúng UML, cần bổ sung sơ đồ use case theo ký pháp của môn học.

Nguồn tạo PNG: DOAN/docs/draw_report_diagrams.py. Các sơ đồ mô tả mã nguồn hiện có, không đưa database hoặc nghiệp vụ thanh toán chưa triển khai vào thiết kế.
''',encoding='utf-8')
print('Created 4 PNG diagrams and 4 Mermaid sources')
