import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ملفات الشاشات
import 'package:flutter_application_1/DoctorAppointmentsPage.dart';
import 'package:flutter_application_1/DoctorsScreen.dart';
import 'package:flutter_application_1/MyBookingsScreen.dart';
import 'package:flutter_application_1/history_screen.dart';
import 'package:flutter_application_1/MyAccountPage.dart';
import 'package:flutter_application_1/Sign_in.dart';
import 'package:flutter_application_1/sign_up.dart';
import 'package:flutter_application_1/chat.dart';

import 'firebase_options.dart';
import 'package:flutter_application_1/api1/firebase_api.dart';

// ✅✅✅ تم إصلاح الخطأ هنا: تعريف متغير الثيم ✅✅✅
//final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// --- دالة استقبال الإشعارات في الخلفية ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🚀 1. التطبيق بدأ");

  // --- تهيئة الفايربيس ---
  try {
    print("⏳ 2. محاولة تهيئة الفايربيس...");
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print("✅ 3. تم تهيئة الفايربيس بنجاح");
  } catch (e) {
    print("❌ خطأ في الفايربيس: $e");
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  try {
    print("⏳ 4. محاولة تهيئة الإشعارات...");
    await FirebaseApi().initNotifications();
    print("✅ 5. تم تهيئة الإشعارات");
  } catch (e) {
    print("❌ خطأ في الإشعارات: $e");
  }

  print("🚀 6. تشغيل الواجهة (runApp)");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 هنا التغيير الجوهري: نستخدم ValueListenableBuilder لمراقبة الثيم
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // الآن أصبح المتغير معرفاً ولن يظهر خطأ
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // تفعيل الثيم الحالي (فاتح أو داكن)
          themeMode: currentMode,

          // إعدادات الوضع الفاتح
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF56BA5B),
            scaffoldBackgroundColor: const Color(0xFFFCF7FD),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),

          // إعدادات الوضع الداكن
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF56BA5B),
            scaffoldBackgroundColor: const Color(0xFF121212), // لون خلفية داكن
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
            ),
            // تخصيص ألوان النصوص في الوضع الداكن إذا لزم الأمر

            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
          ),




          initialRoute: '/',
          routes: {
            '/': (context) => SignUpPage(),
            '/SignIn': (context) => SignIn(),
            '/chatpage': (context) => const ChatScreen(), // تأكد من الاسم
            '/DoctorAppointmentsPage': (context) => DoctorAppointmentsScreen(),
            '/HistoryPage': (context) => const HistoryScreen(),
            '/MyAccountPage': (context) => const MyAccountPage(),
            '/DoctorsScreen': (context) => const DoctorsScreen(),
            '/MyBookingsScreen' : (context) => const MybookingsScreen(),
          },
        );
      },
    );
  }
}

// --- الألوان القديمة (بقيت كما هي) ---
class AppColors {
  static const Color darkSecondary = Color(0xff243E57);
  static const Color defaultBlack = Color(0xFF181E22);
  static const Color primaryBG = Color.fromRGBO(198, 198, 198, 1.0);
  static const Color primary = Color(0xFF15CB95);
  static const Color secondary = Color(0xffff8900);
  static const Color turquoise = Color(0xff00bec5);
  static const Color otherTurquoise = Color(0x0000bec5);
  static const Color magenta = Color(0xffff0bac);
  static const Color otherMagenta = Color(0x00ff0bac);
  static const Color indigo = Color(0xff54086b);
  static const Color black = Color.fromRGBO(0, 0, 0, 1.0);
  static const Color grey = Color(0xffB4B6BC);
  static const Color darkGrey = Color(0xff303437);
  static const Color blackIcons = Color.fromRGBO(5, 5, 5, 1.0);
  static const Color greyIcons = Color.fromARGB(255, 237, 237, 242);
  static const Color white = Color.fromRGBO(255, 255, 255, 1.0);
  static const Color red = Color(0xffff0000);
  static const Color googleLogo = Color(0xffDB4437);
  static const Color flatred = Color.fromRGBO(239, 90, 86, 1.0);
  static const Color thirdWhite = Color(0xffF5F5F7);
  static const Color backgroundColor = Color.fromARGB(255, 242, 241, 241);
  static const Color lightGreyColor = Color.fromRGBO(245, 245, 245, 1.0);
  static const Color success = Color.fromRGBO(0, 168, 98, 1.0);
  static const Color failed = Color.fromRGBO(239, 90, 86, 1.0);
  static const Color shadow = Color.fromRGBO(183, 183, 183, 0.5);
  static const Color notification = Color(0xffC5B100);
  static const Color green = Color(0xff1CD345);
  static const Color orange = Color(0xffE57C00);
  static const Color purple = Color(0xff6F51FE);
  static const Color lightGreen = Color.fromARGB(255, 163, 201, 180);
  static const Color focusColor = Color.fromRGBO(55, 145, 93, 1.0);
  static const Color yellow = Color.fromRGBO(252, 182, 20, 1.0);
  static const Color babyPink = Color(0xfffdcfec);
  static const Color babyBlue = Color(0xffcfdcfd);
  static const Color foshi = Color(0xffebcffd);
  static const Color lemon = Color(0xfffdedcf);
  static const Color darkMood = Color(0xff949494);
  static const Color blue = Color(0xff007AFF);
  static const Color darkBlue = Color.fromARGB(255, 0, 46, 96);
  static const Color lightBlack = Color(0xff303437);
  static const Color lightOrange = Color(0xffFDDACF);
  static const Color textPink = Color(0xffFD17A9);
  static const Color primaryBlueColor = Color(0xff00BEC5);
  static const Color opacityLine = Color(0xff828282);
  static const Color lightFont = Color(0xffBDBDBD);
  static const Color boldTextColor = Color(0xff192126);
}