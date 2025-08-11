import 'package:expense_tracker/model/user.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/services/firebase_services.dart';

class UserInfoDialog extends StatefulWidget {
  final String uid;
  final FirebaseServices firebaseServices;

  const UserInfoDialog({
    Key? key,
    required this.uid,
    required this.firebaseServices,
  }) : super(key: key);

  @override
  State<UserInfoDialog> createState() => _UserInfoDialogState();
}

class _UserInfoDialogState extends State<UserInfoDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final String email = FirebaseAuth.instance.currentUser?.email ?? '';
  bool isLoading = false;

  void _saveUserInfo() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty) {
      setState(() => isLoading = true);

      final user = UserModel(
        id: widget.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now().toIso8601String(),
      );

      await widget.firebaseServices.addUser(user);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Complete Your Profile"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(
                'assets/animations/loading.json',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "Phone Number",
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: isLoading ? null : _saveUserInfo,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
