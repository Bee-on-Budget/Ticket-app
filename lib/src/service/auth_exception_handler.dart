import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  invalidEmail,
  unknown,
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthStatus.invalidEmail;
      case 'wrong-password':
        return AuthStatus.wrongPassword;
      default:
        return AuthStatus.unknown;
    }
  }

  static String generateErrorMessage(AuthStatus error) {
    switch (error) {
      case AuthStatus.wrongPassword:
        return "email or password is wrong.";
      case AuthStatus.invalidEmail:
        return "Your email address appears to be malformed.";
      default:
        return "An error occurred. Please try again later.";
    }
  }
}
