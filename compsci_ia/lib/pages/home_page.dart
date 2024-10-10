import 'package:flutter/material.dart';
import 'Loginpage.dart'; // Import your LoginPage
import 'another_page.dart'; // Import additional pages
import 'settings_page.dart'; // Import the Settings page
import 'placeholder_page.dart'; // Import the Profile page

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Two boxes per row
        children: <Widget>[
          _menuBox(context, 'Login', const LoginPage()),
          _menuBox(context, 'Another Page', const AnotherPage()),
          _menuBox(context, 'Settings', const SettingsPage()),
          _menuBox(context, 'Profile', const ProfilePage()),
        ],
      ),
    );
  }

  // Helper function to create each menu box
  Widget _menuBox(BuildContext context, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(17.0),
        elevation: 4,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
