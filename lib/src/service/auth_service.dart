import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Register a new user and add their data to FireStore
  Future<void> registerUser(
      String email, String password, String fullName, String role) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info in Firestore
      await _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error during registration: $e');
      }
      rethrow;
    }
  }

  Future<void> checkAndAddUserInfo(User user) async {
    try {
      DocumentSnapshot userDoc =
          await _fireStore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _fireStore.collection('users').doc(user.uid).set({
          'fullName': user.displayName ?? 'New User',
          'email': user.email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking/adding user info: $e');
      }
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
