class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'email': email, 'password': password};

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        id: m['id'],
        name: m['name'],
        email: m['email'],
        password: m['password'],
      );
}