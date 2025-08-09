import 'package:expense_tracker/model/expense_model.dart';
import 'package:expense_tracker/model/user.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/screens/chart.dart';
import 'package:expense_tracker/screens/home.dart';
import 'package:expense_tracker/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref();
  final FirebaseServices _firebaseServices = FirebaseServices();
  String userName = '';
  String greeting = '';

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    greeting = getGreeting();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    if (hour < 20) return "Good Evening";
    return "Good Night";
  }

  Future<void> onExpenseAdded(ExpenseModel expenseModel) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomeScreen();
    //var activePageTitle = '';
    if (_selectedPageIndex == 1) {
      activePage = AddExpenseWidget(onExpenseAdded: onExpenseAdded);
    } else if (_selectedPageIndex == 2) {
      activePage = const ChartScreen();
    }
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20,
                  ),
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
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              user?.name ?? "User",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            print("notification button pressed.");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
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
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 28, 11, 66),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white30,
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, color: Colors.white, size: 30),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.white, size: 30),
            label: "Add",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: Colors.white, size: 30),
            label: "Chart",
          ),
        ],
      ),
    );
  }
}
