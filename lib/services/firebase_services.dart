import 'package:expense_tracker/model/expense_model.dart';
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

  Future<void> addExpense(String category, double amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final String currentMonth = DateFormat('MMMMyyyy').format(DateTime.now()); // e.g. August2025
      final String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now()); // e.g. 06-08-2025
      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      final expenseRef = ref.child("Expense").child(uid).child(currentMonth).child(currentDate).push();
      await expenseRef.set({
        'category': category,
        'amount': amount,
      });

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
      double previousIncome = 0;
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        previousIncome = (data['income'] as num).toDouble();
      }

      final totalIncome = previousIncome + incomeModel.income;

      await incomeRef.set({'income': totalIncome});
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
