import 'package:firebase_auth/firebase_auth.dart';

class UserDetails {
  final String uid;
  final String email;

  UserDetails({required this.uid, required this.email});

  factory UserDetails.fromFirebaseUser(User user) {
    return UserDetails(uid: user.uid, email: user.email ?? '');
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserDetails?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        return UserDetails.fromFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error saat signup: ${e.message}');
      return null;
    }
  }

  Future<UserDetails?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        return UserDetails.fromFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error saat login: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserDetails? get currentUser {
    User? user = _auth.currentUser;
    if (user != null) {
      return UserDetails.fromFirebaseUser(user);
    }
    return null;
  }
}
