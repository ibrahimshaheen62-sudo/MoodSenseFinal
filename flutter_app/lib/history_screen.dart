import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ⚠️ تأكد أن هذا المسار يشير لملف الشات الصحيح عندك لاستيراد AppColors
import 'package:flutter_application_1/chat.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // دالة لتقسيم التاريخ
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "اليوم";
    } else if (dateToCheck == yesterday) {
      return "أمس";
    } else if (now.difference(date).inDays < 7) {
      return "الـ 7 أيام الماضية";
    } else {
      return "قديم";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔥 1. كشف الوضع الليلي وضبط الألوان
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // تغيير الأيقونة لسهم أفضل
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("سجل المحادثات", style: TextStyle(color: textColor)),
        actions: [
          IconButton(
            // ✅ تم إصلاح الخطأ هنا: استبدال lightGreen بـ primaryGreen
            icon: const Icon(Icons.add, color: AppColors.primaryGreen),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(conversationId: null),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .collection("conversations")
            .orderBy("last_updated", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ✅ تم إصلاح الخطأ هنا أيضاً
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("لا يوجد محادثات سابقة", style: TextStyle(color: textColor)));
          }

          final docs = snapshot.data!.docs;

          Map<String, List<DocumentSnapshot>> groupedDocs = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['last_updated'] as Timestamp?;
            if (timestamp != null) {
              String label = _getDateLabel(timestamp.toDate());
              if (!groupedDocs.containsKey(label)) {
                groupedDocs[label] = [];
              }
              groupedDocs[label]!.add(doc);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: groupedDocs.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? "محادثة جديدة";
                    final convId = doc.id;

                    return Card(
                      elevation: 0,
                      color: cardColor, // لون الكارد يتغير حسب الثيم
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderColor),
                      ),
                      child: ListTile(
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: textColor), // لون النص
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white54 : Colors.grey),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(conversationId: convId),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}