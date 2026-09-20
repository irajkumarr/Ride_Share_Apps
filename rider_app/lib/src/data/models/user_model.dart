class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePhotoUrl;
  final String? token;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePhotoUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profilePhotoUrl,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      token: token ?? this.token,
    );
  }
}
