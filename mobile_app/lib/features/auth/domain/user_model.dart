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

  bool get isAdmin =>
      role.toLowerCase() == 'super_admin' || role.toLowerCase() == 'company_admin';

  bool get isSuperAdmin => role.toLowerCase() == 'super_admin';

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? 'Operator',
      role: (json['role'] as String? ?? 'operator').toLowerCase(),
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'role': role,
    'token': token,
  };
}
