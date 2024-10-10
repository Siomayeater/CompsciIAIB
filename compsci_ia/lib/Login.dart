import 'package:flutter/material.dart';
import 'login.dart';  // Adjust the path based on where your Login widget is defined

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
        ),
      ),
      home: const LoginPage(),  // Set the LoginPage as the starting page
    );
  }
}
