// lib/data/models/user_model.dart
class UserModel {
  final String username;
  final String email;
  final String password;
  final String? image;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'image': image,
    };
  }
}
