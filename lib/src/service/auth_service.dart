import 'package:firebase_auth/firebase_auth.dart';

import 'auth_exception_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthStatus _status = AuthStatus.unknown;

  Future<AuthStatus> loginViaEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }

  Future<AuthStatus> loginViaPhone({
    required String mobile,
    required String password,
  }) async {
    try {
      mobile += "@phone.com";
      await _auth.signInWithEmailAndPassword(email: mobile, password: password);
      _status = AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
