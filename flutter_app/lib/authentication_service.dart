import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Sign Up Successful!";
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message for display.
    } catch (e) {
      return "An unexpected error occurred";
    }
  }



}
