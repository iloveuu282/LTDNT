using System.Text.Json;

namespace SurveyApi.Api.Models;

public static class SurveyRules
{
    public static void ValidateQuestions(SurveyForm form)
    {
        if (form.Title.Trim().Length<2 || string.IsNullOrWhiteSpace(form.Description))
            throw new ArgumentException("Nhập tiêu đề ít nhất 2 ký tự và mô tả.");
        List<Question> questions;
        try { questions=JsonSerializer.Deserialize<List<Question>>(form.QuestionsJson,Survey.JsonOptions)??[]; }
        catch (JsonException) { throw new ArgumentException("Dữ liệu câu hỏi không hợp lệ."); }
        if (questions.Count is <1 or >50) throw new ArgumentException("Mỗi mẫu cần từ 1 đến 50 câu hỏi.");
        var ids=new HashSet<int>();
        foreach (var q in questions)
        {
            if (q is null || q.Id<1 || !ids.Add(q.Id) || string.IsNullOrWhiteSpace(q.Title) || q.Title.Length>500)
                throw new ArgumentException("Câu hỏi phải có mã riêng và nội dung từ 1 đến 500 ký tự.");
            if (q.Type is not ("text" or "single" or "multiple" or "rating")) throw new ArgumentException("Loại câu hỏi không hợp lệ.");
            if (q.Type is "single" or "multiple")
            {
                if (q.Options is null || q.Options.Count is <2 or >20 || q.Options.Any(o=>string.IsNullOrWhiteSpace(o)||o.Length>200) || q.Options.Distinct().Count()!=q.Options.Count)
                    throw new ArgumentException("Câu chọn đáp án cần 2–20 lựa chọn khác nhau, mỗi lựa chọn tối đa 200 ký tự.");
            }
            else q.Options=[];
        }
        form.QuestionsJson=JsonSerializer.Serialize(questions,Survey.JsonOptions);
    }
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
