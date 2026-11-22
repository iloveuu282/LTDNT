class Member {
  final bool isActive;
  final int memberId;
  final String fullName, email, roleName;
  const Member({
    required this.memberId,
    required this.fullName,
    required this.email,
    required this.roleName,
    this.isActive = true,
  });
  factory Member.fromMap(Map<String, dynamic> map) => Member(
    isActive: map['isActive'] as bool? ?? true,
    memberId: map['memberId'] as int,
    fullName: map['fullName'] as String,
    email: map['email'] as String,
    roleName: map['roleName'] as String,
  );
}
