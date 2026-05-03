import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User will be assigned a user ID when they first register
  Future<void> register({required String name, required String email, required String password}) async{
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password
      );

      final userID = userCredential.user!.uid;

      await _firestore.collection('users').doc(userID).set({
        'name': name,
        'email': email
      });
    
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