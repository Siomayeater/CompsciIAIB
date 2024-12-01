import 'package:flutter/material.dart';
import 'LoginFirebase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Register',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginView(), // Start with the Register Page
    );
  }
}
