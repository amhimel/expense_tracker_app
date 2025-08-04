import 'package:expense_tracker/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseServices {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference dbUserRef = FirebaseDatabase.instance.ref("users");

// get current user (single)
  Stream<UserModel?> getUser() {
    return dbUserRef.child("$uid").onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(data));
    });
  }

  //add user
  Future<void> addUser(UserModel users) async {
    await dbUserRef.child("$uid").set(users.toMap());
  }
}
