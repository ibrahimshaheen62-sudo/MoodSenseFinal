import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

// ⚠️ تأكد من مسارات ملفاتك
import 'history_screen.dart';
import 'MyAccountPage.dart';
import 'Sign_in.dart';
import 'DoctorsScreen.dart';

// 🔥 1. تعريف متغير للتحكم بالثيم (Global Variable)
// هذا المتغير سيسمح بتغيير الثيم في كل التطبيق
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// --- Theme Constants ---
class AppColors {
  // Light Colors
  static const Color background = Color(0xFFFCF7FD);
  static const Color primaryGreen = Color(0xFF56BA5B);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);
  static const Color botBubble = Color(0xFFF0F0F0);
  static const Color userBubble = Color(0xFFE8F5E9);

  // Dark Colors Helpers
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkInput = Color(0xFF2C2C2C);
}

class ChatScreen extends StatefulWidget {
  final String? conversationId;

  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final String apiUrl = "http://192.168.1.173"
      ""
      ""
      ""
      ""
      ":8001/chat";

  late String currentConversationId;
  bool isNewConversation = false;

  final List<String> _suggestions = [
    "كيف أتغلب على القلق؟",
    "نصائح للنوم العميق",
    "تمارين استرخاء",
    "ماهي أعراض القلق",
    "ماهي أعراض الاكتئاب",
    "اعراض التوتر",
    "أعطيني رابط قرآن",
    "بدي فيديو عن تطوير الذات ",
    "أعطيني فيديو يضحكني",
  ];

  final List<Map<String, String>> _medications = [
    {"name": "بروزاك (Prozac)", "desc": "للاكتئاب"},
    {"name": "سيبرالكس (Cipralex)", "desc": "للقلق"},
    {"name": "زولوفت (Zoloft)", "desc": "تحسين المزاج"},
    {"name": "زانكس (Xanax)", "desc": "مهدئ"},
    {"name": "سيروكسات (Seroxat)", "desc": "للرهاب"},
  ];

  @override
  void initState() {
    super.initState();

    if (widget.conversationId != null) {
      currentConversationId = widget.conversationId!;
    } else {
      currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
      isNewConversation = true;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/SignIn');
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMedicalDisclaimerAlways();
    });
  }

  void _showMedicalDisclaimerAlways() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'تنبيه طبي هام',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(
                    'يرجى العلم أن هذا التطبيق يقدم أدوات ومعلومات للمساعدة في مراقبة الحالة المزاجية فقط.',
                    style: TextStyle(height: 1.5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'المعلومات والنتائج المقدمة هنا هي لأغراض استرشادية وليست بديلاً عن الاستشارة الطبية المتخصصة أو التشخيص أو العلاج.',
                    style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'يجب عليك دائماً استشارة طبيب مختص قبل اتخاذ أي قرارات صحية. إذا كنت تشعر بحالة طوارئ، اتصل بالجهات الطبية المختصة فوراً.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'فهمت وأوافق',
                  style: TextStyle(fontSize: 16, color: AppColors.primaryGreen),
                ),
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage(String userMessage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    setState(() => _isLoading = true);

    final conversationRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("conversations")
        .doc(currentConversationId);

    Map<String, dynamic> conversationData = {
      "last_updated": FieldValue.serverTimestamp(),
    };

    if (isNewConversation) {
      conversationData["title"] = userMessage;
      isNewConversation = false;
    }

    await conversationRef.set(conversationData, SetOptions(merge: true));

    await conversationRef.collection("messages").add({
      "role": "user",
      "content": userMessage,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      );

      if (res.statusCode == 200) {
        final botReply = jsonDecode(res.body)["reply"].toString();
        await conversationRef.collection("messages").add({
          "role": "bot",
          "content": botReply,
          "timestamp": FieldValue.serverTimestamp(),
        });
      } else {
        await conversationRef.collection("messages").add({
          "role": "bot",
          "content": "عذراً، حدث خطأ في الاتصال: ${res.statusCode}",
          "timestamp": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      await conversationRef.collection("messages").add({
        "role": "bot",
        "content": "⚠️ مشكلة في الاتصال بالخادم",
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/SignIn', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    // 🔥 2. تحديد ما إذا كان الوضع الليلي مفعلاً
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تعريف الألوان بناءً على الثيم
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final subTextColor = isDark ? Colors.grey.shade400 : AppColors.textLight;

    final Stream<QuerySnapshot> messagesStream = uid == null
        ? const Stream<QuerySnapshot>.empty()
        : FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("conversations")
        .doc(currentConversationId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,

      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textDark), // لون أيقونة القائمة

        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("MOOD", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 4),
                const Icon(Icons.chat_bubble, color: AppColors.primaryGreen, size: 20),
              ],
            ),
            const Text(
              "مساعدك الشخصي",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.primaryGreen),
            tooltip: "محادثة جديدة",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen(conversationId: null)),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      // --- Drawer (تم التعديل لإضافة الـ Switch) ---
      endDrawer: _buildDrawer(isDark, surfaceColor, textColor),

      body: Column(
        children: [
          // --- Top Suggestions Chips ---
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? Colors.transparent : null,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(_suggestions[index]),
                    labelStyle: TextStyle(color: textColor, fontSize: 12),
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
                    side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    shape: const StadiumBorder(),
                    onPressed: () => sendMessage(_suggestions[index]),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: isDark ? Colors.grey.shade800 : const Color(0xFFEEEEEE)),

          // --- Chat Messages Area ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spa, size: 60, color: AppColors.primaryGreen.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text("مرحباً بك! كيف يمكنني مساعدتك اليوم؟", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isUser = data["role"] == "user";
                    return _buildMessageBubble(data["content"] ?? "", isUser, isDark);
                  },
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AppColors.primaryGreen, minHeight: 2),
            ),

          // --- Bottom Input Area ---
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 💊 شريط الأدوية
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final med = _medications[index];
                      return GestureDetector(
                        onTap: () => sendMessage("معلومات عن دواء ${med['name']}"),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8, bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.medication_outlined, color: AppColors.primaryGreen, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                med['name']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                med['desc']!,
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // حقل الكتابة
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInput : AppColors.background,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // أزرار المرفقات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Container(width: 1, height: 24, color: Colors.grey.shade300),
                            IconButton(
                              icon: const Icon(Icons.medical_services_outlined, color: Colors.grey, size: 20),
                              tooltip: "تحدث مع طبيب",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DoctorsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_isLoading,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: textColor), // لون النص أثناء الكتابة
                          decoration: const InputDecoration(
                            hintText: "اكتب رسالتك هنا...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) sendMessage(value);
                          },
                        ),
                      ),

                      // Send Button
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty && !_isLoading) {
                                sendMessage(_controller.text);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildMessageBubble(String message, bool isUser, bool isDark) {
    // ألوان الفقاعات بناءً على الثيم
    final botBubbleColor = isDark ? AppColors.darkInput : AppColors.botBubble;
    final userBubbleColor = isDark ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.userBubble;
    final textColor = isDark ? Colors.white : AppColors.textDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? (isDark ? userBubbleColor : Colors.white) : botBubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser ? Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableLinkify(
                        text: message,
                        style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                        linkStyle: const TextStyle(color: Colors.blue),
                        onOpen: (link) async {
                          if (await canLaunchUrl(Uri.parse(link.url))) {
                            await launchUrl(Uri.parse(link.url));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 40),
              if (!isUser) const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  // --- Drawer Widget with Theme Switch ---
  Widget _buildDrawer(bool isDark, Color surfaceColor, Color textColor) {
    return Drawer(
      backgroundColor: surfaceColor, // لون خلفية القائمة
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryGreen),
            accountName: const Text("User"),
            accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primaryGreen),
            ),
          ),

          ListTile(
            leading: Icon(Icons.history, color: isDark ? Colors.white70 : Colors.black54),
            title: Text("History", style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: isDark ? Colors.white70 : Colors.black54),
            title: Text("My account", style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/MyAccountPage');
            },
          ),

          const Divider(),

          // 🔥🔥 3. إضافة زر التبديل للوضع الليلي في الـ Drawer
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return SwitchListTile(
                title: Text("الوضع الليلي", style: TextStyle(color: textColor)),
                secondary: Icon(
                  currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                value: currentMode == ThemeMode.dark,
                activeColor: AppColors.primaryGreen,
                onChanged: (bool value) {
                  // تحديث القيمة العالمية ليسمعها التطبيق بأكمله
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),

          const Spacer(),
          Divider(height: 1, color: isDark ? Colors.grey.shade700 : Colors.grey),
          ListTile(
            leading: Icon(Icons.logout, color: isDark ? Colors.white70 : Colors.black54),
            title: Text("Log out", style: TextStyle(color: textColor)),
            onTap: _handleSignOut,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}















































// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// // ⚠️ تم الحفاظ على استدعاءات الملفات كما في كودك الأصلي
// import 'history_screen.dart';
// import 'MyAccountPage.dart';
// import 'Sign_in.dart';
// import 'DoctorsScreen.dart';
//
//
// final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
//
// // --- Theme Constants ---
// class AppColors {
//   static const Color background = Color(0xFFFCF7FD); // Pale lavender
//   static const Color primaryGreen = Color(0xFF56BA5B); // Fresh green
//   static const Color lightGreen = Color(0xFF4CAF50);
//   static const Color textDark = Color(0xFF333333);
//   static const Color textLight = Color(0xFF666666);
//   static const Color botBubble = Color(0xFFF0F0F0);
//   static const Color userBubble = Color(0xFFE8F5E9);
//   static const Color darkBackground = Color(0xFF121212);
//   static const Color darkSurface = Color(0xFF1E1E1E);
//   static const Color darkInput = Color(0xFF2C2C2C);
// }
//
// class ChatScreen extends StatefulWidget {
//   final String? conversationId;
//
//   const ChatScreen({super.key, this.conversationId});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = false;
//   // تم الحفاظ على الـ IP الخاص بك
//   final String apiUrl = "http://10.236.250.207:8001/chat";
//
//   late String currentConversationId;
//   bool isNewConversation = false;
//
//   // اقتراحات تظهر في الأعلى
//   final List<String> _suggestions = [
//     "كيف أتغلب على القلق؟",
//     "نصائح للنوم العميق",
//     "تمارين استرخاء",
//     "ماهي أعراض القلق",
//     "ماهي أعراض الاكتئاب",
//     "اعراض التوتر",
//     "أعطيني رابط قرآن",
//     "بدي فيديو عن تطوير الذات ",
//     "أعطيني فيديو يضحكني",
//   ];
//
//   // 💊 قائمة الأدوية المشهورة
//   final List<Map<String, String>> _medications = [
//     {"name": "بروزاك (Prozac)", "desc": "للاكتئاب"},
//     {"name": "سيبرالكس (Cipralex)", "desc": "للقلق"},
//     {"name": "زولوفت (Zoloft)", "desc": "تحسين المزاج"},
//     {"name": "زانكس (Xanax)", "desc": "مهدئ"},
//     {"name": "سيروكسات (Seroxat)", "desc": "للرهاب"},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.conversationId != null) {
//       currentConversationId = widget.conversationId!;
//     } else {
//       currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
//       isNewConversation = true;
//     }
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, '/SignIn');
//       });
//     }
//
//     // 🔥 إضافة كود تشغيل الـ Pop-up (التنبيه الطبي)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showMedicalDisclaimerAlways();
//     });
//   }
//
//   // 🔥 دالة التنبيه الطبي (من الكود الثاني)
//   void _showMedicalDisclaimerAlways() {
//     if (mounted) {
//       showDialog(
//         context: context,
//         barrierDismissible: false, // يمنع إغلاق النافذة بالضغط خارجها
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             title: Row(
//               children: const [
//                 Icon(Icons.warning_amber_rounded, color: Colors.red),
//                 SizedBox(width: 8),
//                 Text(
//                   'تنبيه طبي هام',
//                   style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: const <Widget>[
//                   Text(
//                     'يرجى العلم أن هذا التطبيق يقدم أدوات ومعلومات للمساعدة في مراقبة الحالة المزاجية فقط.',
//                     style: TextStyle(height: 1.5),
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'المعلومات والنتائج المقدمة هنا هي لأغراض استرشادية وليست بديلاً عن الاستشارة الطبية المتخصصة أو التشخيص أو العلاج.',
//                     style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'يجب عليك دائماً استشارة طبيب مختص قبل اتخاذ أي قرارات صحية. إذا كنت تشعر بحالة طوارئ، اتصل بالجهات الطبية المختصة فوراً.',
//                     style: TextStyle(height: 1.5),
//                   ),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text(
//                   'فهمت وأوافق',
//                   style: TextStyle(fontSize: 16, color: AppColors.primaryGreen),
//                 ),
//                 onPressed: () {
//                   if (mounted) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   Future<void> sendMessage(String userMessage) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     final uid = user.uid;
//
//
//
//
//     setState(() => _isLoading = true);
//
//     final conversationRef = FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .collection("conversations")
//         .doc(currentConversationId);
//
//     Map<String, dynamic> conversationData = {
//       "last_updated": FieldValue.serverTimestamp(),
//     };
//
//     if (isNewConversation) {
//       conversationData["title"] = userMessage;
//       isNewConversation = false;
//     }
//
//     await conversationRef.set(conversationData, SetOptions(merge: true));
//
//     await conversationRef.collection("messages").add({
//       "role": "user",
//       "content": userMessage,
//       "timestamp": FieldValue.serverTimestamp(),
//     });
//
//     _controller.clear();
//     _scrollToBottom();
//
//     try {
//       final res = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"message": userMessage}),
//       );
//
//       if (res.statusCode == 200) {
//         final botReply = jsonDecode(res.body)["reply"].toString();
//         await conversationRef.collection("messages").add({
//           "role": "bot",
//           "content": botReply,
//           "timestamp": FieldValue.serverTimestamp(),
//         });
//       } else {
//         await conversationRef.collection("messages").add({
//           "role": "bot",
//           "content": "عذراً، حدث خطأ في الاتصال: ${res.statusCode}",
//           "timestamp": FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       await conversationRef.collection("messages").add({
//         "role": "bot",
//         "content": "⚠️ مشكلة في الاتصال بالخادم",
//         "timestamp": FieldValue.serverTimestamp(),
//       });
//     }
//
//     setState(() => _isLoading = false);
//     _scrollToBottom();
//   }
//
//   // --- دالة تسجيل الخروج ---
//   void _handleSignOut() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;
//     Navigator.pushNamedAndRemoveUntil(context, '/SignIn', (_) => false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final uid = user?.uid;
//
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     // تعريف الألوان بناءً على الثيم
//     final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
//     final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
//     final textColor = isDark ? Colors.white : AppColors.textDark;
//     final subTextColor = isDark ? Colors.grey.shade400 : AppColors.textLight;
//
//
//     final Stream<QuerySnapshot> messagesStream = uid == null
//         ? const Stream<QuerySnapshot>.empty()
//         : FirebaseFirestore.instance
//         .collection("users")
//         .doc(uid)
//         .collection("conversations")
//         .doc(currentConversationId)
//         .collection("messages")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       // --- AppBar ---
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//
//         iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textDark), // لون أيقونة القائمة
//
//         title: Column(
//           children: [
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: const [
//                 Text("MOOD", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
//                 SizedBox(width: 4),
//                 Icon(Icons.chat_bubble, color: AppColors.primaryGreen, size: 20),
//               ],
//             ),
//             const Text(
//               "مساعدك الشخصي",
//               style: TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_comment_outlined, color: AppColors.primaryGreen),
//             tooltip: "محادثة جديدة",
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ChatScreen(conversationId: null)),
//               );
//             },
//           ),
//           Builder(
//             builder: (context) => IconButton(
//               icon: const Icon(Icons.menu, color: AppColors.textDark),
//               onPressed: () => Scaffold.of(context).openEndDrawer(),
//             ),
//           ),
//         ],
//       ),
//
//       // --- Drawer (تم التعديل لإضافة الـ Switch) ---
//       endDrawer: _buildDrawer(isDark, surfaceColor,textColor),
//
//       // --- Drawer ---
//
//
//       body: Column(
//         children: [
//           // --- Top Suggestions Chips ---
//           Container(
//             height: 50,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _suggestions.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   child: ActionChip(
//                     label: Text(_suggestions[index]),
//                     labelStyle: const TextStyle(color: AppColors.textDark, fontSize: 12),
//                     backgroundColor: AppColors.background,
//                     side: BorderSide(color: Colors.grey.shade200),
//                     shape: const StadiumBorder(),
//                     onPressed: () => sendMessage(_suggestions[index]),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           const Divider(height: 1, color: Color(0xFFEEEEEE)),
//
//           // --- Chat Messages Area ---
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: messagesStream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
//                 }
//
//                 final docs = snapshot.data?.docs ?? [];
//
//                 if (docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.spa, size: 60, color: AppColors.primaryGreen.withOpacity(0.5)),
//                         const SizedBox(height: 16),
//                         const Text("مرحباً بك! كيف يمكنني مساعدتك اليوم؟", style: TextStyle(color: Colors.grey)),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data = docs[index].data() as Map<String, dynamic>;
//                     final isUser = data["role"] == "user";
//                     return _buildMessageBubble(data["content"] ?? "", isUser);
//                   },
//                 );
//               },
//             ),
//           ),
//
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: LinearProgressIndicator(color: AppColors.primaryGreen, minHeight: 2),
//             ),
//
//           // --- Expanded Bottom Input Area with Medication Boxes ---
//           Container(
//             padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//
//                 // 💊 شريط الأدوية
//                 SizedBox(
//                   height: 90,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: _medications.length,
//                     itemBuilder: (context, index) {
//                       final med = _medications[index];
//                       return GestureDetector(
//                         onTap: () => sendMessage("معلومات عن دواء ${med['name']}"),
//                         child: Container(
//                           width: 100,
//                           margin: const EdgeInsets.only(right: 8, bottom: 8),
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: AppColors.background,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey.shade200),
//                             boxShadow: [
//                               BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.medication_outlined, color: AppColors.primaryGreen, size: 28),
//                               const SizedBox(height: 4),
//                               Text(
//                                 med['name']!,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 med['desc']!,
//                                 style: const TextStyle(fontSize: 9, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 // حقل الكتابة
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.background,
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       // أزرار المرفقات
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           children: [
//
//                             Container(width: 1, height: 24, color: Colors.grey.shade300),
//                             IconButton(
//                               icon: const Icon(Icons.medical_services_outlined, color: Colors.grey, size: 20),
//                               tooltip: "تحدث مع طبيب",
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const DoctorsScreen()),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Text Field
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           enabled: !_isLoading,
//                           textAlign: TextAlign.right,
//                           textDirection: TextDirection.rtl,
//                           decoration: const InputDecoration(
//                             hintText: "اكتب رسالتك هنا...",
//                             hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
//                           ),
//                           onSubmitted: (value) {
//                             if (value.trim().isNotEmpty) sendMessage(value);
//                           },
//                         ),
//                       ),
//
//                       // Send Button
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: AppColors.primaryGreen,
//                             shape: BoxShape.circle,
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//                             onPressed: () {
//                               if (_controller.text.trim().isNotEmpty && !_isLoading) {
//                                 sendMessage(_controller.text);
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- Helpers ---
//
//   Widget _buildMessageBubble(String message, bool isUser) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Column(
//         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!isUser) ...[
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(
//                     color: AppColors.primaryGreen,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//               Flexible(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: isUser ? Colors.white : AppColors.botBubble,
//                     borderRadius: BorderRadius.only(
//                       topLeft: const Radius.circular(16),
//                       topRight: const Radius.circular(16),
//                       bottomLeft: Radius.circular(isUser ? 16 : 4),
//                       bottomRight: Radius.circular(isUser ? 4 : 16),
//                     ),
//                     border: isUser ? Border.all(color: Colors.grey.shade200) : null,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SelectableLinkify(
//                         text: message,
//                         style: const TextStyle(color: AppColors.textDark, fontSize: 15, height: 1.4),
//                         linkStyle: const TextStyle(color: Colors.blue),
//                         onOpen: (link) async {
//                           if (await canLaunchUrl(Uri.parse(link.url))) {
//                             await launchUrl(Uri.parse(link.url));
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (isUser) const SizedBox(width: 40),
//               if (!isUser) const SizedBox(width: 40),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: AppColors.textLight),
//           const SizedBox(width: 6),
//           Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
//         ],
//       ),
//     );
//   }
//
//   // --- Drawer Widget ---
//   Widget _buildDrawer() {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           UserAccountsDrawerHeader(
//             decoration: const BoxDecoration(color: AppColors.primaryGreen),
//             accountName: const Text("User"),
//             accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
//             currentAccountPicture: const CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(Icons.person, color: AppColors.primaryGreen),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.history, color: Colors.black54),
//             title: const Text("History", style: TextStyle(color: Colors.black)),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HistoryScreen()),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.person_outline, color: Colors.black54),
//             title: const Text("My account", style: TextStyle(color: Colors.black)),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, '/MyAccountPage');
//             },
//           ),
//
//           const Spacer(),
//           const Divider(height: 1, color: Colors.grey),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.black54),
//
//             title: const Text("Log out", style: TextStyle(color: Colors.black)),
//             onTap: _handleSignOut,
//           ),
//           SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
//         ],
//       ),
//     );
//   }
// }