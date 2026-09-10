class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String token;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Operator',
      role: json['role'] as String? ?? 'OPERATOR',
      token: token,
    );
  }
}
