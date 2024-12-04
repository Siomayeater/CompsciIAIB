import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginFirebase.dart'; 

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    hintText: 'Enter your company name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        QuerySnapshot companySnapshot = await _firestore
                            .collection('companies')
                            .where('name', isEqualTo: company)
                            .limit(1)
                            .get();

                        if (companySnapshot.docs.isNotEmpty) {
                          String companyID = companySnapshot.docs.first.id;

                          await _firestore.collection('users').doc(userCredential.user?.uid).set({
                            'email': email,
                            'company': company,
                            'companyID': companyID,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration successful!')),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginView()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Company not found!')),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        String errorMessage = 'An error occurred.';

                        if (e.code == 'email-already-in-use') {
                          errorMessage = 'This email is already registered.';
                        } else if (e.code == 'weak-password') {
                          errorMessage = 'The password is too weak.';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMessage)),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('An unexpected error occurred.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to Login', style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
