class Category {
  final int? id;
  final String name;
  final String title;
  final String description;
  final String icon;
  Category({
    this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
  });
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['categoryId'],
      name: map['categoryName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      'categoryName': name,
      'title': title,
      'description': description,
      'icon': icon,
    };
    if (id != null) {
      map['categoryId'] = id;
    }
    return map;
  }
}