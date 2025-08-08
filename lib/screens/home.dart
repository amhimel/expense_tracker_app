import 'package:expense_tracker/model/income.dart';
import 'package:expense_tracker/model/user.dart';
import 'package:expense_tracker/services/firebase_services.dart';
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
  double _income = 0.0;
  double _expenses = 0.0;
  double _totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    // Add post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // wait for Auth to complete
      await checkUserInfo();
    });
  }
  Future<void> _handleAddIncome(double income) async {
    await _firebaseServices.addIncome(IncomeModel(income: income));
    setState(() {}); // Refresh UI if needed
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
                            setState(
                              () => isLoading = true,
                            ); // ✅ Use dialog's setState here
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
      body: StreamBuilder<double>(
        stream: _firebaseServices.getCurrentlyInputIncome(),
        builder: (context, incomeSnapshot) {
          return StreamBuilder<double>(
            stream: _firebaseServices.getTotalIncome(),
            builder: (context, totalIncomeSnapshot) {
              return StreamBuilder<double>(
                stream: _firebaseServices.getMonthlyExpense,
                builder: (context, expenseSnapshot) {
                  if (!incomeSnapshot.hasData ||
                      !totalIncomeSnapshot.hasData ||
                      !expenseSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final income = incomeSnapshot.data!;
                  final expenses = expenseSnapshot.data!;
                  final totalBalance = totalIncomeSnapshot.data!;
                  return BalanceCardWidget(
                      totalBalance: totalBalance,
                      income: income,
                      expenses: expenses,
                      onIncomeAdded: _handleAddIncome
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
