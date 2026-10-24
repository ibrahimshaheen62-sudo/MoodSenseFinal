import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 1. إضافة هذه المكتبة للتحقق من الويب
import 'package:flutter_application_1/history_screen.dart';
// نستخدم (as google_lib) لتجنب التضارب مع الملفات القديمة
import 'package:google_sign_in/google_sign_in.dart' as google_lib;
import 'package:flutter_application_1/Sign_in.dart';
import 'package:flutter_application_1/chat.dart';
import 'package:flutter_application_1/api1/firebase_api.dart';

// ملاحظة: قمت بإزالة استيراد Colors.dart لأننا نستخدم كلاس الألوان في الأسفل

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // --- دالة تسجيل الدخول عبر Google (المعدلة للويب والموبايل) ---
  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. إعداد GoogleSignIn مع شرط الويب
      final google_lib.GoogleSignIn googleSignIn = google_lib.GoogleSignIn(
        // إذا كان ويب، نستخدم الـ ID، وإذا كان موبايل نتركه null
        clientId: kIsWeb
            ? "235663911511-4apt5qni4u4em5f7nmpbhqfj5npi7ork.apps.googleusercontent.com" // ⚠️ الصق الرقم هنا
            : null,
      );

      // 3. بدء عملية التسجيل
      final google_lib.GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // المستخدم أغلق النافذة
      }

      // 4. الحصول على التوكن
      final google_lib.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 5. إنشاء الاعتماد (Credential)
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 6. الدخول لفايربيس
      await _auth.signInWithCredential(credential);

      // 7. حفظ توكن الإشعارات (اختياري)
      try {
        await FirebaseApi().initNotifications();
      } catch (e) {
        print("Error saving notification token: $e");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign In Successful!")),
        );
        // الانتقال للصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign In Failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ---------------------------------------------------------

  void _signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        try {
          await FirebaseApi().initNotifications();
          print("Token saved successfully after Sign Up");
        } catch (e) {
          print("Error saving token: $e");
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign Up Successful!")),
          );
        }

        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignIn()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error during sign up: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'MOOD ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'SENSE',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Create an account",
                  style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your email to sign up for this app",
                  style: TextStyle(color: AppColors.black, fontSize: 14),
                ),
                const SizedBox(height: 28),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.black),
                    hintText: "email@domain.com",
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                    hintText: "Password",
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                    hintText: "Confirm Password",
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add_alt_1, color: AppColors.white),
                        SizedBox(width: 8),
                        Text(
                          "Sign up",
                          style: TextStyle(color: AppColors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // OR Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColors.black, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "OR",
                        style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.black, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 16),

                // Google Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _signInWithGoogle(context),
                    icon: const Icon(Icons.login, color: AppColors.black),
                    label: const Text("Continue with Google",
                        style: TextStyle(color: AppColors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(color: AppColors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Apple Button


                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  },
                  child: const Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text.rich(
                  TextSpan(
                    text: "By clicking Sign Up, you agree to our ",
                    style: TextStyle(color: AppColors.black, fontSize: 12),
                    children: [
                      TextSpan(
                          text: "Terms", style: TextStyle(color: AppColors.black)),
                      TextSpan(text: ", "),
                      TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(color: AppColors.black)),
                      TextSpan(text: " and "),
                      TextSpan(
                          text: "Cookies Policy",
                          style: TextStyle(color: AppColors.black)),
                      TextSpan(text: "."),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// كلاس الألوان في الأسفل (احتفظنا به هنا لضمان عدم وجود أخطاء استيراد)
class AppColors {
  static const Color darkSecondary = Color(0xff243E57);
  static const Color defaultBlack = Color(0xFF181E22);
  static const Color primaryBG = Color.fromRGBO(198, 198, 198, 1.0);
  static const Color primary = Color(0xFF15CB95);
  static const Color secondary = Color(0xffff8900);
  static const Color turquoise = Color(0xff00bec5);
  static const Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static const Color grey = Color(0xffB4B6BC);
  static const Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color red = Color(0xffff0000);
  static const Color googleLogo = Color(0xffDB4437);
  static const Color green = Color(0xff1CD345);
  static const Color lightGreen = Color.fromARGB(255, 163, 201, 180);
}