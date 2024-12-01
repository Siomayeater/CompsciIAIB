import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginFirebase.dart'; // Correct import

class RegisterPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController companyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(
                hintText: 'Enter your company name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final company = companyController.text.trim();

                if (email.isNotEmpty && password.isNotEmpty && company.isNotEmpty) {
                  try {
                    // Create user in Firebase Authentication
                    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // Log user UID for debugging
                    print('User UID: ${userCredential.user?.uid}');

                    // Save additional user data to Firestore
                    await _firestore.collection('users').doc(userCredential.user?.uid).set({
                      'email': email,
                      'company': company,
                    }).then((value) {
                      print('User data saved to Firestore');
                    }).catchError((error) {
                      print('Error saving user data to Firestore: $error');
                    });

                    // Show confirmation message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful!')),
                    );

                    // Navigate to LoginFirebase after successful registration
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  } on FirebaseAuthException catch (e) {
                    String errorMessage = 'An error occurred.';

                    // Print out the error details for debugging
                    print('Auth Error: ${e.message}');
                    print('Auth Error Code: ${e.code}');

                    if (e.code == 'email-already-in-use') {
                      errorMessage = 'This email is already registered.';
                    } else if (e.code == 'weak-password') {
                      errorMessage = 'The password is too weak.';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                );
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
