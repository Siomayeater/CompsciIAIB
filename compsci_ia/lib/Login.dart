
import 'package:flutter/material.dart';
import 'pages/login_page.dart';  // Import login page
import 'Main.dart';  // Import any database-related functionality

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: LoginPage(),  // Set the LoginPage as the starting page
    );
  }
}