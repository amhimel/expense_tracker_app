import 'package:expense_tracker/model/income.dart';
import 'package:expense_tracker/model/user.dart';
import 'package:expense_tracker/services/firebase_services.dart';
import 'package:expense_tracker/widgets/add_income_dialog_widget.dart';
import 'package:expense_tracker/widgets/balance_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref();
  final FirebaseServices _firebaseServices = FirebaseServices();
  String userName = '';
  String greeting = '';

  @override
  void initState() {
    super.initState();
    // Add post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500)); // wait for Auth to complete
      await checkUserInfo();
    });
    greeting = getGreeting();

  }

  void addUser() {}

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  Future<void> checkUserInfo() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    print("Current UID: $currentUid");

    if (currentUid == null) {
      print("UID is null. Skipping check.");
      return;
    }

    final snapshot = await dbRef.child("users/$currentUid").get();
    if (!snapshot.exists) {
      print("User info not found. Showing dialog...");
      showUserInfoDialog();
    } else {
      print("User info already exists.");
    }
  }

  Future<void> _handleAddIncome(double income) async {
    await _firebaseServices.addIncome(IncomeModel(income: income));
    setState(() {}); // Refresh UI if needed
  }


  void showUserInfoDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          // 🔥 For updating isLoading within dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Complete Your Profile"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    const SizedBox(height: 20),
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
                  ],
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
                  onPressed: isLoading
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();

                    if (name.isNotEmpty && phone.isNotEmpty) {
                      setState(() => isLoading = true); // ✅ Use dialog's setState here
                      final user = UserModel(
                        id: uid,
                        name: name,
                        email: email,
                        phone: phone,
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      await _firebaseServices.addUser(user);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 28, 11, 66),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: StreamBuilder<UserModel?>(
              stream: _firebaseServices.getUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getGreeting()},",
                              style: const TextStyle(fontSize: 20, color: Colors.white70),
                            ),
                            Text(
                              user?.name ?? "User",
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: (){
                            print("add button pressed.");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications, color: Colors.white),
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BalanceCardWidget(
              totalBalance: 18000,
              income: 15000,
              expenses: 13500,
              onIncomeAdded: _handleAddIncome,
            ),

          ],
        ),

    );
  }
}