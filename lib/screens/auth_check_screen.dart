import 'package:expense_tracker/screens/home.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    // 🔐 Check Firebase Auth user
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final storedUid = await secureStorage.read(key: 'user_id');

    if (firebaseUser != null && storedUid != null && firebaseUser.uid == storedUid) {
      // ✅ User is logged in and verified
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // ⛔ Not logged in or secure storage empty
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
