import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp(String email, String password) async {
    final userCredential =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<User?> signIn(String email, String password) async {
    final userCredential =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> resetPassword(String email) async =>
      _auth.sendPasswordResetEmail(email: email);
}
