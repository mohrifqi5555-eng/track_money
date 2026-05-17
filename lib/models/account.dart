import 'dart:convert';

class Account {
  final String id;
  String username;
  String email;
  String password;
  String profilePhoto;
  double initialBalance;

  Account({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.profilePhoto,
    this.initialBalance = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profilePhoto': profilePhoto,
      'initialBalance': initialBalance,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      initialBalance: (map['initialBalance'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Account.fromJson(String source) => Account.fromMap(json.decode(source));
}
