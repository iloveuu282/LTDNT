# Đoạn code thật cần giải thích

Các đoạn dưới lấy trực tiếp từ mã nguồn khi tạo tài liệu. Mục tiêu là hiểu, không học thuộc. Tên phương thức là cách tìm bền vững hơn số dòng. Không có khóa hoặc mật khẩu thật trong các đoạn trích.

## setState và mounted
[survey_list_view.dart](<../cuoiki/survey_app/lib/pages/survey_list_view.dart>) — dòng 47. Đoạn trích dòng 47 đến 76; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```dart
    final request = ++_request;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final categories = await SurveyRepository.categories();
      if (_category != null &&
          !categories.any((c) => c.categoryId == _category)) {
        _category = null;
        _page = 1;
      }
      final data = await SurveyRepository.getPage(
        _page,
        _category,
        _search.text.trim(),
      );
      if (mounted && request == _request) {
        setState(() {
          _categories = categories;
          _items = data.items;
          _total = data.total;
        });
      }
    } catch (e) {
      if (mounted && request == _request) setState(() => _error = errorText(e));
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }
```

_request tăng theo mỗi lần tải. Chỉ request mới nhất còn hiệu lực mới ghi state; mounted bảo vệ khi trang đã đóng. Cờ busy/lỗi điều khiển giao diện, không thay cho quyền server.

## Multipart ảnh danh mục
[survey_repository.dart](<../cuoiki/survey_app/lib/repositories/survey_repository.dart>) — dòng 15. Đoạn trích dòng 15 đến 49; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```dart
  static Future<void> saveCategory(
    int? id,
    String name,
    String description, {
    XFile? image,
    bool removeImage = false,
  }) async {
    final request = http.MultipartRequest(
      id == null ? 'POST' : 'PUT',
      Uri.parse(
        '${ApiService.baseUrl}/api/categories${id == null ? '' : '/$id'}',
      ),
    );
    request.headers['Authorization'] = 'Bearer ${await SessionHelper.token}';
    request.fields.addAll({
      'categoryName': name,
      'description': description,
      'removeImage': '$removeImage',
    });
    if (image != null) {
      if (await image.length() > 5242880) throw Exception('Ảnh tối đa 5 MB.');
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
    await ApiService.upload(request);
  }

  static Future<void> deleteCategory(int id) async {
    await ApiService.request('DELETE', 'categories/$id');
  }

  static Future<PageData<Survey>> getPage(
    int page,
    int? categoryId,
    String search,
  ) async {
```

URI dùng baseUrl đang cấu hình. Header Bearer xác thực. fields là tên/mô tả/cờ bỏ ảnh, files là dữ liệu ảnh. Không jsonEncode file ảnh thành chuỗi thường.

## Lưu nháp SQLite
[local_database.dart](<../cuoiki/survey_app/lib/local/local_database.dart>) — dòng 40. Đoạn trích dòng 40 đến 57; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```dart
  static Future<void> saveDraft(
    int memberId,
    int itemId,
    int campaignId,
    String payload,
  ) async {
    final db = await open();
    await db.insert('response_drafts', {
      'member_id': memberId,
      'item_id': itemId,
      'campaign_id': campaignId,
      'payload_json': payload,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, Object?>?> draft(int memberId, int itemId) async {
    final rows = await (await open()).query(
```

insert vào response_drafts với ConflictAlgorithm.replace: trùng khóa ghép thì thay bản nháp. memberId và itemId phân biệt dữ liệu; mỗi lần lưu tạo lại thời gian cập nhật.

## Lưu payload nháp
[response_page.dart](<../cuoiki/survey_app/lib/pages/response_page.dart>) — dòng 58. Đoạn trích dòng 58 đến 68; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```dart
  Future<void> _store() async => LocalDatabase.saveDraft(
    widget.memberId,
    widget.itemId,
    widget.campaignId,
    jsonEncode({
      'survey': _survey!.toMap(),
      'answers': _answers,
      'submissionId': _submissionId,
    }),
  );
  Future<void> _save() async {
```

Nội dung mẫu, map đáp án và mã gửi được lưu cùng nhau. Có bản mẫu mới mở nháp offline; giữ mã gửi mới thử lại an toàn khi server đã nhận nhưng client chưa nhận được phản hồi.

## Đăng ký ép vai trò Member
[MemberRepository.cs](<../cuoiki/SurveyApi/Api/Models/MemberRepository.cs>) — dòng 20. Đoạn trích dòng 20 đến 27; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public Task<int> Add(RegisterModel model) => connection.QuerySingleAsync<int>(
        """
        INSERT INTO Members (FullName, Email, PasswordHash, RoleId)
        OUTPUT INSERTED.MemberId
        VALUES (@FullName, @Email, @PasswordHash, (SELECT RoleId FROM Roles WHERE RoleName = 'Member'))
        """, new { FullName = model.FullName.Trim(), Email = model.Email.Trim().ToLowerInvariant(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.Password) });

```

RoleId lấy bằng truy vấn RoleName Member, không tin role client gửi. Email lowercase/trim; BCrypt tạo hash. SQL parameter tách giá trị khỏi câu lệnh.

## Phát hành JWT
[AuthController.cs](<../cuoiki/SurveyApi/Api/Controllers/AuthController.cs>) — dòng 37. Đoạn trích dòng 37 đến 47; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
        var expires = DateTime.UtcNow.AddHours(8);
        var token = new JwtSecurityToken(configuration["Jwt:Issuer"], configuration["Jwt:Audience"],
            [new Claim(ClaimTypes.NameIdentifier, member.MemberId.ToString()),
             new Claim(ClaimTypes.Role, member.RoleName),
             new Claim("version", member.TokenVersion.ToString())],
            expires: expires,
            signingCredentials: new SigningCredentials(new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(configuration["Jwt:SecretKey"]!)), SecurityAlgorithms.HmacSha256));
        return Ok(new { token = new JwtSecurityTokenHandler().WriteToken(token), expiresAt = expires,
            member = PublicMember(member) });
    }
```

JWT sống 8 giờ, có id, role và version. Chữ ký HMAC SHA256 dùng secret của server. Payload JWT không tự được mã hóa; không thêm mật khẩu vào claims.

## Kiểm tra phiên mỗi request
[Program.cs](<../cuoiki/SurveyApi/Program.cs>) — dòng 26. Đoạn trích dòng 26 đến 40; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
        OnTokenValidated = async context =>
        {
            var idText = context.Principal?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(idText, out var id)) { context.Fail("Invalid member"); return; }
            var provider = context.HttpContext.RequestServices.GetRequiredService<SiteProvider>();
            var member = await provider.Member.FindById(id);
            if (member is null || !member.IsActive ||
                context.Principal?.FindFirst("version")?.Value != member.TokenVersion.ToString() ||
                context.Principal?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value != member.RoleName)
                context.Fail("Session expired");
        }
    };
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true,
```

Sau khi middleware kiểm tra chữ ký/thời hạn, app đọc trạng thái thành viên từ DB. Khóa tài khoản, tăng TokenVersion hoặc đổi role làm token cũ thất bại mà không phải chờ hết 8 giờ.

## Thay ảnh chỉ xóa cũ sau khi lưu
[CategoryController.cs](<../cuoiki/SurveyApi/Api/Controllers/CategoryController.cs>) — dòng 30. Đoạn trích dòng 30 đến 47; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public async Task<IActionResult> Update(int id,[FromForm] CategoryForm model)
    {
        if(model.CategoryName.Trim().Length<2 || (model.RemoveImage && model.Image is not null))
            return BadRequest(new {message="Tên ít nhất 2 ký tự. Không đồng thời thay và xóa ảnh."});
        string? path=null;
        try
        {
            if(model.Image is not null) path=await images.Save(model.Image);
            var old=await provider.Category.Update(id,model,path);
            path=null;
            images.Delete(old);
            return Ok(new {message="Đã cập nhật danh mục."});
        }
        catch(ArgumentException ex) {return BadRequest(new {message=ex.Message});}
        catch(KeyNotFoundException ex) {return NotFound(new {message=ex.Message});}
        catch(SqlException ex) when(ex.Number is 2601 or 2627) {return Conflict(new {message="Tên danh mục đã tồn tại."});}
        finally {images.Delete(path);}
    }
```

Update lưu ảnh mới rồi gọi repository ghi dữ liệu. Sau khi repository commit, path=null để finally không xóa ảnh mới đã dùng, rồi xóa old. Khi ghi lỗi, path vẫn giữ ảnh mới nên finally dọn file mới. Tên trùng không làm mất ảnh cũ.

## Khóa mẫu khi sửa
[SurveyRepository.cs](<../cuoiki/SurveyApi/Api/Models/SurveyRepository.cs>) — dòng 41. Đoạn trích dòng 41 đến 62; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public async Task<string?> Update(int id, SurveyForm form, string? newImage)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var transaction = connection.BeginTransaction(IsolationLevel.Serializable);
        var current = await connection.QuerySingleOrDefaultAsync<Survey>("SELECT * FROM Surveys WITH (UPDLOCK,HOLDLOCK) WHERE SurveyId=@id", new { id }, transaction);
        if (current is null) throw new KeyNotFoundException("Không tìm thấy mẫu khảo sát.");
        if (await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM CampaignItems WHERE SurveyId=@id", new { id }, transaction)>0)
            throw new InvalidOperationException("Mẫu đã có trong chiến dịch, không được sửa. Hãy tạo mẫu mới.");
        await connection.ExecuteAsync("""
            UPDATE Surveys SET CategoryId=@CategoryId,Title=@title,Description=@description,
                QuestionsJson=@QuestionsJson,ImagePath=@image WHERE SurveyId=@id
            """, new { id, form.CategoryId, title=form.Title.Trim(), description=form.Description.Trim(), form.QuestionsJson, image=newImage??current.ImagePath }, transaction);
        transaction.Commit();
        return newImage is null ? null : current.ImagePath;
    }

    public async Task<string> Delete(int id)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var transaction = connection.BeginTransaction(IsolationLevel.Serializable);
        var path = await connection.QuerySingleOrDefaultAsync<string>("SELECT ImagePath FROM Surveys WITH (UPDLOCK,HOLDLOCK) WHERE SurveyId=@id",new { id },transaction);
        if (path is null) throw new KeyNotFoundException("Không tìm thấy mẫu khảo sát.");
```

Serializable và khóa bản ghi phối hợp với bước checkout để không sửa nội dung đúng lúc mẫu được triển khai. Kiểm tra CampaignItems trước UPDATE; không chỉ disable nút Sửa trên Flutter.

## Tạo chiến dịch không trùng
[CampaignRepository.cs](<../cuoiki/SurveyApi/Api/Models/CampaignRepository.cs>) — dòng 26. Đoạn trích dòng 26 đến 51; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public async Task<int> Checkout(int memberId,CheckoutModel model)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var existing=await connection.QuerySingleOrDefaultAsync<int?>(
            "SELECT CampaignId FROM Campaigns WITH (UPDLOCK,HOLDLOCK) WHERE MemberId=@memberId AND RequestId=@RequestId",new { memberId,model.RequestId },tx);
        if (existing.HasValue) return existing.Value;
        var plan=(await connection.QueryAsync<PlanItem>(
            "SELECT * FROM PlanItems WITH (UPDLOCK,HOLDLOCK) WHERE MemberId=@memberId",new { memberId },tx)).ToList();
        if (plan.Count==0) throw new InvalidOperationException("Kế hoạch chưa có mẫu khảo sát.");
        // Giữ khóa mẫu đến khi ghi CampaignItems để không sửa câu hỏi giữa lúc triển khai.
        await connection.QueryAsync<int>("SELECT SurveyId FROM Surveys WITH (HOLDLOCK) WHERE SurveyId IN @ids",new { ids=plan.Select(p=>p.SurveyId) },tx);
        var id=await connection.QuerySingleAsync<int>(
            "INSERT INTO Campaigns(MemberId,Title,RequestId) OUTPUT INSERTED.CampaignId VALUES(@memberId,@title,@RequestId)",new { memberId,title=model.Title.Trim(),model.RequestId },tx);
        foreach (var item in plan)
            await connection.ExecuteAsync("INSERT INTO CampaignItems(CampaignId,SurveyId,TargetCount) VALUES(@id,@SurveyId,@TargetCount)",new { id,item.SurveyId,item.TargetCount },tx);
        await connection.ExecuteAsync("DELETE FROM PlanItems WHERE MemberId=@memberId",new { memberId },tx);
        tx.Commit();
        return id;
    }

    public async Task<PageResult<Campaign>> GetPage(int memberId,bool admin,bool open,int page,int size,string? search,DateTime? start,DateTime? end)
    {
        const string where="""
             WHERE ((@open=1 AND c.Status='Active') OR (@open=0 AND (@admin=1 OR c.MemberId=@memberId)))
             AND (c.Title LIKE @keyword OR c.CampaignId=@code)
```

Tìm RequestId cũ trước, đọc kế hoạch, chèn campaign/items và xóa plan trong một transaction. Commit ở cuối file hàm. Có lỗi trước commit thì rollback khi Dispose, tránh tạo dở chiến dịch hoặc làm mất kế hoạch.

## Gửi phản hồi và kiểm tra trước đó
[CampaignRepository.cs](<../cuoiki/SurveyApi/Api/Models/CampaignRepository.cs>) — dòng 74. Đoạn trích dòng 74 đến 95; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public async Task Submit(int campaignId,int itemId,int memberId,ResponseModel model)
    {
        if (connection.State != ConnectionState.Open) connection.Open();
        using var tx=connection.BeginTransaction(IsolationLevel.Serializable);
        var status=await connection.QuerySingleOrDefaultAsync<string>("SELECT Status FROM Campaigns WITH (UPDLOCK,HOLDLOCK) WHERE CampaignId=@campaignId",new { campaignId },tx);
        var item=await connection.QuerySingleOrDefaultAsync<CampaignItem>("SELECT * FROM CampaignItems WHERE CampaignId=@campaignId AND ItemId=@itemId",new { campaignId,itemId },tx);
        if (item is null) throw new KeyNotFoundException("Không tìm thấy khảo sát trong chiến dịch.");
        var previous=await connection.QuerySingleOrDefaultAsync<Guid?>("SELECT SubmissionId FROM Responses WHERE ItemId=@itemId AND MemberId=@memberId",new { itemId,memberId },tx);
        if (previous==model.SubmissionId) return; // thử gửi lại cùng mã không tạo bản ghi trùng
        if (previous.HasValue) throw new InvalidOperationException("Bạn đã trả lời khảo sát này.");
        if (status!="Active") throw new InvalidOperationException("Chiến dịch chưa mở hoặc đã kết thúc.");
        var count=await connection.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM Responses WHERE ItemId=@itemId",new { itemId },tx);
        if (count>=item.TargetCount) throw new InvalidOperationException("Khảo sát đã đủ số phản hồi mục tiêu.");
        var survey=await connection.QuerySingleAsync<Survey>("SELECT * FROM Surveys WHERE SurveyId=@SurveyId",new { item.SurveyId },tx);
        SurveyRules.ValidateAnswers(survey.Questions,model.Answers);
        await connection.ExecuteAsync("INSERT INTO Responses(ItemId,MemberId,SubmissionId,AnswersJson) VALUES(@itemId,@memberId,@SubmissionId,@json)",
            new { itemId,memberId,model.SubmissionId,json=JsonSerializer.Serialize(model.Answers) },tx);
        tx.Commit();
    }
    public Task<IEnumerable<string>> Answers(int campaignId,int itemId) => connection.QueryAsync<string>(
        "SELECT r.AnswersJson FROM Responses r JOIN CampaignItems i ON i.ItemId=r.ItemId WHERE i.CampaignId=@campaignId AND i.ItemId=@itemId ORDER BY r.ResponseId",new { campaignId,itemId });
}
```

Giữ khóa chiến dịch, kiểm tra ItemId thuộc chiến dịch, phản hồi cũ, status, mục tiêu và đáp án rồi INSERT. Cùng SubmissionId là retry thành công, khác mã mà đã có phản hồi là xung đột. Luồng này xử lý yêu cầu đồng thời tại server.

## Kiểm tra từng loại câu trả lời
[SurveyRules.cs](<../cuoiki/SurveyApi/Api/Models/SurveyRules.cs>) — dòng 30. Đoạn trích dòng 30 đến 51; nếu kết thúc giữa hàm, mở file để xem phần còn lại.

```csharp
    public static void ValidateAnswers(List<Question> questions,Dictionary<string,JsonElement> answers)
    {
        if (answers.Keys.Any(k=>!questions.Any(q=>q.Id.ToString()==k))) throw new ArgumentException("Có câu trả lời không thuộc khảo sát.");
        foreach (var q in questions)
        {
            answers.TryGetValue(q.Id.ToString(),out var value);
            var empty=value.ValueKind is JsonValueKind.Undefined or JsonValueKind.Null ||
                (value.ValueKind==JsonValueKind.String && string.IsNullOrWhiteSpace(value.GetString())) ||
                (value.ValueKind==JsonValueKind.Array && value.GetArrayLength()==0);
            if (empty) { if (q.Required) throw new ArgumentException($"Chưa trả lời: {q.Title}"); continue; }
            bool valid=q.Type switch
            {
                "text" => value.ValueKind==JsonValueKind.String && value.GetString()!.Length<=2000,
                "single" => value.ValueKind==JsonValueKind.String && q.Options.Contains(value.GetString()!),
                "multiple" => value.ValueKind==JsonValueKind.Array && value.EnumerateArray().All(v=>v.ValueKind==JsonValueKind.String && q.Options.Contains(v.GetString()!)) && value.EnumerateArray().Select(v=>v.GetString()).Distinct().Count()==value.GetArrayLength(),
                "rating" => value.ValueKind==JsonValueKind.Number && value.TryGetInt32(out var n) && n>=1 && n<=5,
                _ => false
            };
            if (!valid) throw new ArgumentException($"Câu trả lời không hợp lệ: {q.Title}");
        }
    }
}
```

JsonElement cho biết kiểu dữ liệu thực nhận. Không nhận câu hỏi lạ, đánh giá phải số nguyên 1–5, chọn nhiều không lặp và chỉ chứa lựa chọn trong mẫu. Không tin validation Flutter là đủ.
