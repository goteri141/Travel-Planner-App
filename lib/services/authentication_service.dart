import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register({required String name, required String email, required String password}) async{
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password);
  }

  Future<UserCredential> signIn({required String email, required String password}) async{
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  User? get currentUser => _auth.currentUser;


}