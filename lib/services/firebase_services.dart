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

  String getCurrentMonth() {
    // e.g., August2025
    return DateFormat('MMMMyyyy').format(DateTime.now());
  }

  //get total income
  Stream<double> getTotalIncome() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    return dbIncomeRef
        .child(uid)
        .child(getCurrentMonth())
        .child('totalIncome')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data is num) {
            return data.toDouble();
          } else if (data is String) {
            return double.tryParse(data) ?? 0.0;
          } else {
            return 0.0;
          }
        });
  }

  /// Get income for currently added
  Stream<double> getCurrentlyInputIncome() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Return an empty stream with an error if not logged in
      return Stream.error("User not logged in");
    }

    return dbIncomeRef
        .child(uid)
        .child(getCurrentMonth())
        .child('income')
        .onValue
        .map((event) {
          final value = event.snapshot.value;
          if (value is num) {
            return value.toDouble();
          } else if (value is String) {
            return double.tryParse(value) ?? 0.0;
          } else {
            return 0.0;
          }
        });
  }

  Stream<Map<String, List<ExpenseModel>>> getExpensesGroupedByDate() {
    final uid = _auth.currentUser?.uid;
    return FirebaseDatabase.instance
        .ref()
        .child('Expense')
        .child(uid!)
        .child(getCurrentMonth())
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map?;
          if (data == null) return {};
          final Map<String, List<ExpenseModel>> groupedData = {};
          data.forEach((date, expensesMap) {
            final dayExpenses = <ExpenseModel>[];
            if (expensesMap is Map) {
              expensesMap.forEach((key, value) {
                dayExpenses.add(
                  ExpenseModel.fromMap(Map<String, dynamic>.from(value)),
                );
              });
            }

            groupedData[date] = dayExpenses;
          });

          return groupedData;
        });
  }

  //get monthly total expense
  Stream<double> get getMonthlyExpense {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return FirebaseDatabase.instance
        .ref()
        .child('Expense')
        .child(uid)
        .child(getCurrentMonth())
        .onValue
        .map((event) {
          final snapshot = event.snapshot;
          double totalExpense = 0.0;
          if (snapshot.value != null) {
            final daysMap = Map<String, dynamic>.from(snapshot.value as Map);

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
        });
  }

  //add expense
  Future<void> addExpense(String category, double amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final String currentDate = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now()); // e.g. 06-08-2025
      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      final expenseRef = ref
          .child("Expense")
          .child(uid)
          .child(getCurrentMonth())
          .child(currentDate)
          .push();
      await expenseRef.set({'category': category, 'amount': amount});

      // Subtract from income
      final incomeRef = ref.child("income").child(uid).child(getCurrentMonth());
      final snapshot = await incomeRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        final currentTotalIncome = (data['totalIncome'] as num).toDouble();
        final updatedIncome = currentTotalIncome - amount;
        await incomeRef.update({'totalIncome': updatedIncome});
      }
    }
  }

  //add income
  Future<void> addIncome(IncomeModel incomeModel) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // final String currentMonth = DateFormat('MMMMyyyy').format(DateTime.now());
      final incomeRef = dbIncomeRef.child(uid).child(getCurrentMonth());

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
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await dbIncomeRef
          .child(uid)
          .child(getCurrentMonth())
          .update(income.toMap());
    }
  }

  Stream<UserModel?> getUser() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return dbUserRef.child(uid).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(data));
    });
  }

  //add user
  Future<void> addUser(UserModel users) async {
    final uid = _auth.currentUser?.uid;
    await dbUserRef.child("$uid").set(users.toMap());
  }
}
