import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/widgets/add_income_dialog_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// void _onNotificationTap(NotificationResponse response) {
//   final context = navigatorKey.currentContext;
//   if (context != null) {
//     showDialog(
//       context: context,
//       builder: (context) => const AddIncomeDialogWidget(),
//     );
//   }
// }


void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  // Initialize Flutter Local Notifications Plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    //onDidReceiveNotificationResponse: _onNotificationTap,
  );

  runApp(const App());
}
