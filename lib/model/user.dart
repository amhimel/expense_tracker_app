class UserModel {
  UserModel({required this.id, required this.name, required this.phone, required this.email , required this.createdAt});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ,
      email: map['email'] ,
      phone: map['phone'] ,
      createdAt: map['createdAt'] ,
    );
  }
  String? id;
  String name;
  String phone;
  String email;
  String createdAt;

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email, 'createdAt': createdAt};
  }
}
