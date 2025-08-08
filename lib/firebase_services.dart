import 'package:expense_tracker/model/income.dart';
import 'package:expense_tracker/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference dbUserRef = FirebaseDatabase.instance.ref("users");
  final DatabaseReference dbIncomeRef = FirebaseDatabase.instance.ref("income");

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //get total income
  Future<double> getTotalIncome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    final String currentMonth = DateFormat(
      'MMMMyyyy',
    ).format(DateTime.now()); // e.g., August2025

    final snapshot = await dbIncomeRef
        .child(uid)
        .child(currentMonth)
        .child('totalIncome')
        .get();

    if (snapshot.exists) {
      final value = snapshot.value;
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }

  /// Get income for currently added
  Future<double> getCurrentlyInputedIncome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    final String currentMonth = DateFormat(
      'MMMMyyyy',
    ).format(DateTime.now()); // e.g., August2025

    final snapshot = await dbIncomeRef
        .child(uid)
        .child(currentMonth)
        .child('income')
        .get();

    if (snapshot.exists) {
      final value = snapshot.value;
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }

  //get monthly total expense
  Future<double> getMonthlyExpense() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    final currentMonth = DateFormat('MMMMyyyy').format(DateTime.now());
    final expenseRef = FirebaseDatabase.instance
        .ref()
        .child('Expense')
        .child(uid)
        .child(currentMonth);
    final snapshot = await expenseRef.once();
    double totalExpense = 0.0;
    if (snapshot.snapshot.value != null) {
      final daysMap = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

      for (var dayEntry in daysMap.entries) {
        final expensesInDay = Map<String, dynamic>.from(dayEntry.value);

        for (var expenseEntry in expensesInDay.entries) {
          final expenseData = Map<String, dynamic>.from(
            expenseEntry.value as Map,
          );
          final amount = expenseData['amount'];
          if (amount != null) {
            totalExpense += double.tryParse(amount.toString()) ?? 0.0;
          }
        }
      }
    }

    return totalExpense;
  }

  //add expense
  Future<void> addExpense(String category, double amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final String currentMonth = DateFormat(
        'MMMMyyyy',
      ).format(DateTime.now()); // e.g. August2025
      final String currentDate = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now()); // e.g. 06-08-2025
      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      final expenseRef = ref
          .child("Expense")
          .child(uid)
          .child(currentMonth)
          .child(currentDate)
          .push();
      await expenseRef.set({'category': category, 'amount': amount});

      // Subtract from income
      final incomeRef = ref.child("income").child(uid).child(currentMonth);
      final snapshot = await incomeRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        final currentIncome = (data['income'] as num).toDouble();
        final updatedIncome = currentIncome - amount;
        await incomeRef.update({'income': updatedIncome});
      }
    }
  }

  //add income
  Future<void> addIncome(IncomeModel incomeModel) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final String currentMonth = DateFormat('MMMMyyyy').format(DateTime.now());
      final incomeRef = dbIncomeRef.child(uid).child(currentMonth);

      final snapshot = await incomeRef.get();
      double previousTotalIncome = 0;
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        previousTotalIncome = (data['totalIncome'] as num).toDouble();
      }

      final totalIncome = previousTotalIncome + incomeModel.income;

      await incomeRef.set({
        'income': incomeModel.income,
        'totalIncome': totalIncome,
      });
    }
  }

  Future<void> updateIncome(IncomeModel income) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    //final randomRef = dbIncomeRef.push();
    //final randomKey = randomRef.key;
    if (uid != null) {
      // Get current month like "Aug2025"
      final String currentMonth = DateFormat('MMMMyyyy').format(DateTime.now());
      await dbIncomeRef.child(uid).child(currentMonth).update(income.toMap());
    }
  }

  Stream<UserModel?> getUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return dbUserRef.child(uid).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(data));
    });
  }

  //add user
  Future<void> addUser(UserModel users) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await dbUserRef.child("$uid").set(users.toMap());
  }
}
