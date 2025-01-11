  // import 'package:flutter/material.dart';
  // import 'package:firebase_auth/firebase_auth.dart';

  // class AppleSignInButton extends StatelessWidget {
  //   final FirebaseAuth _auth = FirebaseAuth.instance;

  //   Future<User?> _signInWithApple() async {
  //     final AuthorizationCredentialAppleID credential =
  //         await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName
  //       ],
  //     );

  //     final OAuthCredential appleCredential =
  //         OAuthProvider('apple.com').credential(
  //       idToken: credential.identityToken,
  //       accessToken: credential.authorizationCode,
  //     );

  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(appleCredential);
  //     return userCredential.user;
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     return ElevatedButton(
  //       onPressed: () async {
  //         final User? user = await _signInWithApple();
  //         if (user != null) {
  //           Navigator.pushReplacementNamed(context, '/home');
  //         }
  //       },
  //       child: Text('Sign in with Apple'),
  //     );
  //   }
  // }
