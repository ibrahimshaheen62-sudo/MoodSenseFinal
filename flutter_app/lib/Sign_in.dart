import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 1. استدعاء ملف الـ API
import 'package:flutter_application_1/api1/firebase_api.dart';
import 'package:flutter_application_1/chat.dart';

// ⚠️ تأكد من استدعاء ملف صفحة الشات هنا لكي يعمل الانتقال
// أو استبدل ChatScreen() بالاسم الصحيح للكلاس الخاص بك إذا كان مختلفاً

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // 1. محاولة تسجيل الدخول
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      final user = cred.user;
      if (user == null) {
        throw Exception('User is null after sign in');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully')),
      );

      // 2. تهيئة الإشعارات
      try {
        await FirebaseApi().initNotifications();
        print("✅ Token refreshed and saved upon login");
      } catch (e) {
        print("⚠️ Error saving token during login: $e");
      }

      // 3. الانتقال مباشرة إلى صفحة ChatScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          // تأكد أن ChatScreen هو اسم الكلاس في ملف الشات عندك
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.message ?? e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  "Log in to your account",
                  style: TextStyle(fontSize: 28, color: Colors.green.shade400),
                ),
                const SizedBox(height: 8),
                const Text("Enter your email and password to continue"),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _hide = !_hide),
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  onSubmitted: (_) => _signIn(),
                  textInputAction: TextInputAction.go,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _busy
                        ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white))
                        : const Text("Login",
                        style:
                        TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text("Don’t have an account? Sign up"),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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