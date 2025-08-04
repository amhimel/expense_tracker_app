class UserModel {
  UserModel({required this.id, required this.name, required this.email , required this.createdAt});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ,
      email: map['email'] ,
      createdAt: map['createdAt'] ,
    );
  }
  String? id;
  String name;
  String email;
  String createdAt;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'createdAt': createdAt};
  }
}
