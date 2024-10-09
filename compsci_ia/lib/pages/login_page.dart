import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for the input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simulate a login function
  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Simple validation logic
    if (username == 'admin' && password == '1234') {
      _showDialog('Login Successful', 'Welcome, $username!');
    } else {
      _showDialog('Login Failed', 'Invalid username or password');
    }
  }

  // Function to show alert dialog
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Username field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,  // Hides the password
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Login button
            ElevatedButton(
              onPressed: _login,  // Call login function when pressed
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
