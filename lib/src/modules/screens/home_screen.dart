import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser; // Get the currently logged-in user

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? '',
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome, ${user?.email ?? 'User'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              if (user != null)
                Text(
                  'User ID: ${user.uid}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
