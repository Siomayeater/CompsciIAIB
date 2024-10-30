import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive is used for local data storage
import 'Login.dart';  // Importing the MyApp widget from my_app.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await _initHive();  // Initializes Hive (local database)
  runApp( const MyApp());  // Runs the MyApp widget
  await Firebase.initializeApp();
  runApp(MyApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();  // Initializes Hive for Flutter
  await Hive.openBox("login");  // Opens or creates a Hive box (database) for login data
  await Hive.openBox("accounts");  // Opens or creates a Hive box for account data
}
