import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_exception_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  AuthStatus _status = AuthStatus.unknown;

  Future<void> getFiles({
    required String ticketId,
    required String fileId,
  }) async {
    final files = _fireStore
        .collection('tickets')
        .doc(ticketId)
        .collection('files')
        .doc(fileId);
  }

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
