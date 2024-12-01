import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';  // Import the generated firebase_options.dart
import 'LoginFirebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures proper binding

  // Initialize Firebase with the FirebaseOptions for web (or appropriate platform)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Web',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginView(),  // Your login screen widget
    );
  }
}
