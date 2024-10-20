import 'package:flutter/material.dart';
import 'pages/home_page.dart';  // Adjust the path based on your project structure

void main() => runApp(const MyApp());

// The Login Page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 0.0,
                  )
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Username',  // Added hint text
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: TextField(
                obscureText: true,  // Hide password
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[300],
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Password',  // Added hint text
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to MainMenu (HomePage) after login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),  // Navigates to HomePage
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// A dummy route before showing the login page
class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to LoginPage when the button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('Open Login Page'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
        ),
      ),
      home: const FirstRoute(),  // Set FirstRoute as the initial screen
    );
  }
}
