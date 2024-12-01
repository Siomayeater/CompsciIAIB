import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'RegisterFirebase.dart';
import 'package:compsci_ia/pages/home_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final enteredEmail = _email.text;
                final enteredPassword = _password.text;

                if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter both email and password')),
                  );
                  return;
                }

                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                    email: enteredEmail,
                    password: enteredPassword,
                  );

                  // Fetch company data for the logged-in user
                  Map<String, String> userData = await getCompanyForUser();
                  String company = userData['company'] ?? 'Unknown';
                  String companyID = userData['companyID'] ?? 'Unknown';

                  // Navigate to HomePage with company and companyID
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        company: company,
                        companyID: companyID,
                      ),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  print('FirebaseAuthException: ${e.code}');
                  if (e.code == 'user-not-found') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found!')),
                    );
                  } else if (e.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wrong password!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Authentication error!')),
                    );
                  }
                } on FirebaseException catch (e) {
                  print('FirebaseException: ${e.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Firebase error: ${e.message}')),
                  );
                } catch (e) {
                  print('General Exception: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('An unexpected error occurred.')),
                  );
                }
              },
              child: const Text('Log In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('Back to Register'),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch company data and companyID for the logged-in user
  Future<Map<String, String>> getCompanyForUser() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();

        // Get companyID directly from user document
        String companyID = userSnapshot['companyID'] ?? 'Unknown';
        
        // Optionally fetch company name if needed (but it's not required for authorization)
        String company = userSnapshot['company'] ?? 'Unknown';

        return {'company': company, 'companyID': companyID};
      } on FirebaseException catch (e) {
        print('Error fetching user data: ${e.message}');
        return {'company': 'Unknown', 'companyID': 'Unknown'};
      }
    }
    return {'company': 'Unknown', 'companyID': 'Unknown'};
  }
}
