class MyUserEntity {
  String userId;
  String email;
  String name;
  String? role;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    this.role,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> document) {
    return MyUserEntity(
      userId: document['userId'],
      email: document['email'],
      name: document['name'],
      role: document['role'],
    );
  }
}