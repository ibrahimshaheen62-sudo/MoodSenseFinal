import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد إنك ضفت مكتبة url_launcher في pubspec.yaml

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {

  // دالة الاتصال بالمريض
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        print("Could not launch dialer");
      }
    } catch (e) {
      print("Error launching dialer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // جيب إيميل الدكتور الحالي عشان نجيب بس مواعيده
    final user = FirebaseAuth.instance.currentUser;
    final doctorEmail = user?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("مواعيدي (لوحة الطبيب)"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if(!mounted) return;
              Navigator.pushReplacementNamed(context, '/'); // ارجع لصفحة الدخول
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorEmail', isEqualTo: doctorEmail) // الفلتر: جيب حجوزات هذا الدكتور بس
            .orderBy('date') // رتبهم حسب التاريخ
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.calendar_today, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("لا يوجد مواعيد محجوزة حالياً", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.green),
                  ),
                  title: Text(
                    "المريض: ${data['userEmail'] ?? 'غير معروف'}", // هون ممكن تعرض الاسم لو خزنته
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${data['date']} - ${data['day']}"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${data['time']}"),
                        ],
                      ),
                      if(data['phoneNumber'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "📱 رقم الهاتف: ${data['phoneNumber']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        if (data['phoneNumber'] != null) {
                          _makePhoneCall(data['phoneNumber']);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("رقم الهاتف غير متوفر")),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}