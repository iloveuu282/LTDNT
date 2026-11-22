class Category {
  final int categoryId;
  final String categoryName, description;
  final String? imagePath;
  Category.fromMap(Map<String, dynamic> m)
    : categoryId = m['categoryId'] as int,
      categoryName = m['categoryName'] as String,
      description = m['description'] as String? ?? '',
      imagePath = m['imagePath'] as String?;
}

class Question {
  final int id;
  final String title, type;
  final bool required;
  final List<String> options;
  Question({
    required this.id,
    required this.title,
    required this.type,
    required this.required,
    required this.options,
  });
  factory Question.fromMap(Map<String, dynamic> m) => Question(
    id: m['id'] as int,
    title: m['title'] as String,
    type: m['type'] as String,
    required: m['required'] as bool,
    options: (m['options'] as List).cast<String>(),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type,
    'required': required,
    'options': options,
  };
}

class Survey {
  Map<String, dynamic> toMap() => {
    'surveyId': surveyId,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'title': title,
    'description': description,
    'imagePath': imagePath,
    'isUsed': isUsed,
    'questions': questions.map((q) => q.toMap()).toList(),
  };
  final int surveyId, categoryId;
  final String title, description, imagePath, categoryName;
  final bool isUsed;
  final List<Question> questions;
  Survey.fromMap(Map<String, dynamic> m)
    : surveyId = m['surveyId'] as int,
      categoryId = m['categoryId'] as int,
      title = m['title'] as String,
      description = m['description'] as String,
      imagePath = m['imagePath'] as String,
      categoryName = m['categoryName'] as String,
      isUsed = m['isUsed'] as bool,
      questions = (m['questions'] as List)
          .map((q) => Question.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList();
}

class PlanItem {
  final int surveyId, targetCount;
  final String title;
  PlanItem.fromMap(Map<String, dynamic> m)
    : surveyId = m['surveyId'] as int,
      targetCount = m['targetCount'] as int,
      title = m['title'] as String;
}

class Campaign {
  final int campaignId, memberId;
  final String title, status, fullName, createdAt;
  Campaign.fromMap(Map<String, dynamic> m)
    : campaignId = m['campaignId'] as int,
      memberId = m['memberId'] as int,
      title = m['title'] as String,
      status = m['status'] as String,
      fullName = m['fullName'] as String,
      createdAt = m['createdAt'] as String;
  static String statusText(String status) =>
      const {
        'Pending': 'Chờ duyệt',
        'Active': 'Đang mở',
        'Closed': 'Đã đóng',
        'Cancelled': 'Đã hủy',
      }[status] ??
      status;
}

class CampaignItem {
  final int itemId, surveyId, targetCount, responseCount;
  final String title;
  final bool hasResponded;
  CampaignItem.fromMap(Map<String, dynamic> m)
    : itemId = m['itemId'] as int,
      surveyId = m['surveyId'] as int,
      targetCount = m['targetCount'] as int,
      responseCount = m['responseCount'] as int,
      title = m['title'] as String,
      hasResponded = m['hasResponded'] as bool;
}

class PageData<T> {
  final List<T> items;
  final int total;
  PageData(this.items, this.total);
}
