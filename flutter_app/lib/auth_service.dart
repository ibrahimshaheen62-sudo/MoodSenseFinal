import 'package:firebase_auth/firebase_auth.dart';
// لاحظ هنا: أضفنا (as google_lib) وهذا هو الحل السحري للإيرور
import 'package:google_sign_in/google_sign_in.dart' as google_lib;
import 'package:flutter/material.dart';




class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // لاحظ هنا: استخدمنا الاسم المستعار (google_lib) لإنشاء النسخة
  final google_lib.GoogleSignIn _googleSignIn = google_lib.GoogleSignIn();

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Sign Up Successful!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // دالة تسجيل الدخول عبر جوجل
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // 1. استخدام الاسم المستعار هنا أيضاً
      final google_lib.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // 2. استخدام الاسم المستعار هنا
      final google_lib.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. إنشاء التوكن (تم تصحيح accessToken هنا كما أخبرتك سابقاً)
      final OAuthCredential credential = GoogleAuthProvider.credential(
       accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل تسجيل الدخول: $e")),
        );
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}