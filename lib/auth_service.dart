import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi signup dengan email dan password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error saat signup: ${e.message}');
      return null;
    }
  }

  // Fungsi login dengan email dan password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error saat login: ${e.message}');
      return null;
    }
  }

  // Fungsi logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;
}
