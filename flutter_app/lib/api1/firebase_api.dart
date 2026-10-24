import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  // كائنات للتعامل مع الفايربيس
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // دالة تهيئة الإشعارات الرئيسية
  Future<void> initNotifications() async {
    // 1. طلب الإذن
    await _firebaseMessaging.requestPermission();

    // 2. جلب التوكن الحالي
    final fCMToken = await _firebaseMessaging.getToken();

    print('=======================================');
    print('Token: $fCMToken');
    print('=======================================');

    // 3. حفظ التوكن في الداتابيز إذا كان موجوداً
    if (fCMToken != null) {
      await saveTokenToFirestore(fCMToken);
    }

    // 4. مراقبة تغيير التوكن (لو تغير فجأة، نحدثه في الداتابيز)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToFirestore(newToken);
    });
  }

  // --- دالة مساعدة لحفظ التوكن في Firestore ---
  Future<void> saveTokenToFirestore(String token) async {
    // نتأكد أولاً أن هناك مستخدم مسجل دخول
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // نفترض أن بيانات المستخدمين مخزنة في كوليكشن اسمه 'users'
      // إذا كان اسم الكوليكشن عندك مختلف (مثلاً 'clients') غيره هنا
      await _firestore.collection('users').doc(currentUser.uid).set(
        {
          'fcmToken': token, // اسم الحقل الجديد
        },
        SetOptions(merge: true), // مهم جداً: دمج البيانات لكي لا نحذف اسم المستخدم أو إيميله القديم
      );
      print("✅ تم حفظ التوكن في حساب المستخدم: ${currentUser.email}");
    } else {
      print("⚠️ لم يتم حفظ التوكن لأن المستخدم غير مسجل دخول حالياً");
    }
  }
}