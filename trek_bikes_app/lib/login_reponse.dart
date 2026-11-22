class LoginReponse {
  final bool success;
  final String? token;
  final String message;
  LoginReponse({
    required this.success,
    required this.token,
    required this.message,
  });
  factory LoginReponse.fromMap(Map<String, dynamic> map) {
    return LoginReponse(
      success: map['success'],
      token: map['token'],
      message: map['message'],
    );
  }
}