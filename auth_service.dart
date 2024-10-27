import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method for signing up a user
  Future<User?> signUp(
    String name,
    String phone,
    String eventRole,
    String email,
    String password,
  ) async {
    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      // Store additional user info directly in Firestore under the "users" collection
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'name': name,
          'phone': phone,
          'eventRole': eventRole,
          'email': email,
          'password': password,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('User info saved to Firestore successfully.');
      }

      return user;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  // Method for signing in a user
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
}
