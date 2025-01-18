import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> _getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user signed in.'))
          : FutureBuilder<DocumentSnapshot>(
              future: _getUserData(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('User data not found.'));
                }

                // Safe way to get data from Firestore
                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData == null) {
                  return const Center(child: Text('No user data available.'));
                }

                String fullName = userData['fullName'] ?? 'User';
                String role = userData['role'] ?? 'user';

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome, $fullName'),
                      Text('Role: $role'),
                      if (role == 'admin')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/adminPanel');
                          },
                          child: const Text('Go to Admin Panel'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
