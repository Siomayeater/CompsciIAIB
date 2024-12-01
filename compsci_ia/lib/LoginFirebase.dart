import 'package:firebase_auth/firebase_auth.dart';
import 'package:compsci_ia/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'RegisterFirebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
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

                      try {
                        final userCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: enteredEmail,
                          password: enteredPassword,
                        );

                        // Fetch company data for the logged-in user
                        Map<String, String> userData = await getCompanyForUser();
                        String company = userData['company'] ?? 'Unknown';
                        String companyID = userData['companyID'] ?? 'Unknown'; // Default to 'Unknown'

                        // Navigate to HomePage with company and companyID
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              company: company,
                              companyID: companyID, // Pass companyID (even if it's 'Unknown')
                            ),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        print('Error: ${e.code}');
                        if (e.code == 'user-not-found') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not found!'),
                            ),
                          );
                        } else if (e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wrong password!'),
                            ),
                          );
                        }
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
            );
          } else {
            // Show a loading indicator while Firebase is initializing
            return const Center(child: CircularProgressIndicator());
          }
        },
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

        // Safely retrieve 'company' field, defaulting to 'Unknown' if it doesn't exist
        String company = userSnapshot['company'] ?? 'Unknown';
        
        // For now, just return the company without companyID
        return {'company': company, 'companyID': 'Unknown'};  // Default companyID as 'Unknown'
      } catch (e) {
        print('Error fetching user data: $e');
        return {'company': 'Unknown', 'companyID': 'Unknown'};
      }
    }
    return {'company': 'Unknown', 'companyID': 'Unknown'};
  }
}
