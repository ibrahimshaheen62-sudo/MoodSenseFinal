import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/DoctorsScreen.dart'; // تأكد أن AppColors موجود هنا

// 1. الكلاس الأول: الـ Widget
class MybookingsScreen extends StatefulWidget {
  const MybookingsScreen({super.key});

  @override
  State<MybookingsScreen> createState() => _MybookingsScreenState();
}

// 2. الكلاس الثاني: الـ State (هذا الذي كان ناقصاً)
class _MybookingsScreenState extends State<MybookingsScreen> {

  // دالة الحذف (توضع هنا داخل الـ State)
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إلغاء الموعد"),
        content: const Text("هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
              if (mounted) { // استخدمنا mounted للتأكد من أن الشاشة ما زالت مفتوحة
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إلغاء الموعد بنجاح")),
                );
              }
            },
            child: const Text("نعم، إلغاء", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("حجوزاتي")),
        body: const Center(child: Text("يرجى تسجيل الدخول لعرض الحجوزات")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "حجوزاتي",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // جلب الحجوزات الخاصة بالمستخدم فقط
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // استخدمنا أيقونة بديلة لأن calendar_off قد لا تكون متوفرة في كل النسخ
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  const Text("لا توجد حجوزات حالياً", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: const Border(right: BorderSide(color: AppColors.primaryGreen, width: 4)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['doctorName'] ?? 'طبيب',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['doctorSpecialty'] ?? '',
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
    Text("${data['date']} (${data['day']})", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
          Text("${data['time']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.emergencyRed),
                          onPressed: () => _confirmDelete(context, docId),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}