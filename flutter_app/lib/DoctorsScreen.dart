import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// تأكد من أن هذا الملف موجود في مشروعك أو قم بتعديل المسار
import 'package:flutter_application_1/MyBookingsScreen.dart';

class AppColors {
  static const Color background = Color(0xFFFCF7FD);
  static const Color primaryGreen = Color(0xFF56BA5B);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);
  static const Color emergencyRed = Color(0xFFFF5252);
  static const Color starYellow = Color(0xFFFFC107);
}

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  final List<Map<String, dynamic>> doctors = const [
    {
      "name": "د. محمد علي",
      "email": "dr.mohammad@gmail.com",
      "phone": "0791234567",
      "specialty": "استشاري الطب النفسي وعلاج القلق",
      "rating": 4.8,
      "reviews": 120,
      "image": "assets/images/png/dr1.png",
      "about": "خبرة 15 عاماً في العلاج السلوكي المعرفي.",
      "availableDays": ["Sunday", "Tuesday", "Thursday"],
      "availableTimes": ["10:00 AM", "11:00 AM", "01:00 PM"]
    },
    {
      "name": "د. سارة أحمد",
      "email": "dr.sara@gmail.com",
      "phone": "0787654321",
      "specialty": "أخصائية علم النفس السريري",
      "rating": 4.9,
      "reviews": 85,
      "image": "assets/images/png/dr2.png",
      "about": "متخصصة في علاج اضطرابات الشخصية.",
      "availableDays": ["Monday", "Wednesday", "Saturday"],
      "availableTimes": ["02:00 PM", "03:00 PM", "04:00 PM", "05:00 PM"]
    },
    {
      "name": "د. خالد يوسف",
      "email": "dr.khaled@gmail.com",
      "phone": "0771122334",
      "specialty": "علاج الاكتئاب والصدمات",
      "rating": 4.7,
      "reviews": 200,
      "image": "assets/images/png/dr3.png",
      "about": "عالج أكثر من 500 حالة تعافي تام.",
      "availableDays": ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday"],
      "availableTimes": ["09:00 AM", "12:00 PM", "03:00 PM"]
    },
    {
      "name": "د. ليلى حسن",
      "email": "dr.laila@gmail.com",
      "phone": "0799988776",
      "specialty": "استشارات أسرية وتربوية",
      "rating": 4.9,
      "reviews": 150,
      "image": "assets/images/png/dr4.png",
      "about": "مساعدة العائلات على تجاوز الأزمات.",
      "availableDays": ["Friday", "Saturday"],
      "availableTimes": ["04:00 PM", "05:00 PM", "06:00 PM", "07:00 PM"]
    },
    {
      "name": "د. عمر فاروق",
      "email": "dr.omar@gmail.com",
      "phone": "0785554433",
      "specialty": "علاج الإدمان وإعادة التأهيل",
      "rating": 4.6,
      "reviews": 95,
      "image": "assets/images/png/dr5.png",
      "about": "برامج متخصصة للتعافي من الإدمان.",
      "availableDays": ["Monday", "Thursday"],
      "availableTimes": ["10:30 AM", "11:30 AM", "12:30 PM"]
    },
    {
      "name": "د. ماجد أكرم ",
      "email": "dr.reem@gmail.com",
      "phone": "0776667788",
      "specialty": "طب نفسي للأطفال والمراهقين",
      "rating": 5.0,
      "reviews": 60,
      "image": "assets/images/png/dr6.png",
      "about": "أسلوب لطيف ومحبب للأطفال.",
      "availableDays": ["Sunday", "Tuesday", "Wednesday"],
      "availableTimes": ["03:00 PM", "03:30 PM", "04:00 PM"]
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint("Could not launch dialer");
      }
    } catch (e) {
      debugPrint("Error launching dialer: $e");
    }
  }

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '911',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showBookingSheet(BuildContext context, Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingBottomSheet(doctor: doctor),
    );
  }

  // >>>>> دالة عرض التقييمات المعدلة لتعمل مع الفايربيس <<<<<
  void _showReviewsSheet(BuildContext context, Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // رأس القائمة
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "آراء المرضى عن ${doctor['name']}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // قائمة التقييمات من الفايربيس
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reviews')
                      .where('doctorId', isEqualTo: doctor['email'])
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                "يرجى التحقق من الاتصال أو الـ Console لإنشاء Index.\nالخطأ: ${snapshot.error}",
                                textAlign: TextAlign.center),
                          ));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.rate_review_outlined,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("لا توجد تقييمات بعد، كن أول من يقيم!",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    final reviews = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) =>
                      const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final data = reviews[index].data() as Map<String, dynamic>;

                        // معالجة التاريخ
                        String dateStr = "";
                        if (data['createdAt'] != null) {
                          Timestamp t = data['createdAt'];
                          dateStr = DateFormat('yyyy/MM/dd').format(t.toDate());
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                  AppColors.primaryGreen.withOpacity(0.2),
                                  child: Text(
                                    (data['userEmail'] ?? "U")
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (data['userEmail'] ?? "مستخدم").split('@')[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(dateStr,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 10)),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${data['rating']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (data['comment'] != null &&
                                data['comment'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(right: 50),
                                child: Text(
                                  data['comment'],
                                  style: const TextStyle(
                                      color: AppColors.textDark, height: 1.4),
                                ),
                              ),
                            ]
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // زر إضافة التقييم
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10)
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // فتح ديالوج التقييم فوق القائمة الحالية
                    _showRatingDialog(context, doctor);
                  },
                  icon: const Icon(Icons.add_comment, color: Colors.white),
                  label: const Text("أضف تقييمك وتجربتك",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> doctor) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        double rating = 0;
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                "قيّم تجربتك مع ${doctor['name']}",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("اضغط على النجوم للتقييم"),
                    const SizedBox(height: 10),
                    // استبدل الـ Row القديم بهذا الكود
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // استخدام mainAxisSize: MainAxisSize.min يساعد أحياناً في تقليص العرض
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return IconButton(
                          // 1. إزالة الحواف الداخلية
                          padding: EdgeInsets.zero,

                          // 2. 🔥 هذا السطر هو الأهم: يلغي الحجم الإجباري للزر (48 بكسل) ويجعله بحجم الأيقونة فقط
                          constraints: const BoxConstraints(),

                          // 3. إضافة ستايل لتقريب المسافات إذا لزم الأمر
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),

                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: AppColors.starYellow,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => rating = index + 1.0);
                          },
                        );
                      }),
                    ),








                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: List.generate(5, (index) {
                    //     return IconButton(
                    //       padding: EdgeInsets.zero,
                    //       icon: Icon(
                    //         index < rating ? Icons.star : Icons.star_border,
                    //         color: AppColors.starYellow,
                    //         size: 32,                                            // 32 : stars size
                    //       ),
                    //       onPressed: () {
                    //         setState(() => rating = index + 1.0);
                    //       },
                    //     );
                    //   }),
                    // ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "اكتب تعليقك هنا... (اختياري)",
                        hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: const Text("إلغاء",
                        style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    if (rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text("يرجى اختيار عدد النجوم")));
                      return;
                    }

                    setState(() => isSubmitting = true);

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      // حفظ التقييم في Firebase
                      await FirebaseFirestore.instance
                          .collection('reviews')
                          .add({
                        'doctorId': doctor['email'],
                        'doctorName': doctor['name'],
                        'userId': user?.uid,
                        'userEmail': user?.email,
                        'rating': rating,
                        'comment': commentController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: AppColors.primaryGreen,
                              content: Text(
                                  "شكراً! تم إرسال تقييمك بنجاح.")));
                    } catch (e) {
                      setState(() => isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("حدث خطأ: $e")));
                    }
                  },
                  child: isSubmitting
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text("إرسال التقييم",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.emergencyRed, size: 30),
            SizedBox(width: 10),
            Text("مساعدة طارئة", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "إذا كنت تشعر بأنك في خطر أو تراودك أفكار لإيذاء النفس، يرجى الاتصال بالطوارئ فوراً أو التحدث إلى شخص تثق به.",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _callEmergency();
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: const Text("اتصل بـ 911",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmergencyDialog(context),
        backgroundColor: AppColors.emergencyRed,
        icon: const Icon(Icons.sos, color: Colors.white),
        label: const Text("طوارئ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "الأطباء المختصون",
          style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MybookingsScreen()),
              );
            },
            icon: const Icon(Icons.calendar_month,
                color: AppColors.primaryGreen, size: 20),
            label: const Text("حجوزاتي",
                style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade800, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "تنويه: هذا التطبيق للاستشارات غير الطارئة. في الحالات الحرجة استخدم زر الطوارئ.",
                    style:
                    TextStyle(color: Colors.orange.shade900, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: AssetImage(doctor['image']),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor['name'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text(doctor['specialty'],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight)),
                                const SizedBox(height: 8),
                                InkWell(
                                  // عند الضغط هنا ستفتح قائمة المراجعات من الفايربيس
                                  onTap: () =>
                                      _showReviewsSheet(context, doctor),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text("${doctor['rating']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text(
                                          "(${doctor['reviews']} تقييم)",
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 11,
                                              decoration:
                                              TextDecoration.underline)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => _makePhoneCall(doctor['phone']),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.phone,
                                            color: AppColors.primaryGreen,
                                            size: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        doctor['phone'],
                                        style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _showRatingDialog(context, doctor),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primaryGreen),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("قيم الطبيب",
                                  style:
                                  TextStyle(color: AppColors.primaryGreen)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showBookingSheet(context, doctor),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("حجز موعد",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookingBottomSheet({super.key, required this.doctor});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  bool _isLoading = false;

  List<DateTime> _availableDates = [];
  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _availableTimes = List<String>.from(widget.doctor['availableTimes']);
    _generateDoctorDates();
  }

  void _generateDoctorDates() {
    List<String> doctorWorkingDays =
    List<String>.from(widget.doctor['availableDays']);
    DateTime current = DateTime.now();
    for (int i = 0; i < 30; i++) {
      DateTime date = current.add(Duration(days: i));
      String dayName = DateFormat('EEEE').format(date);
      if (doctorWorkingDays.contains(dayName)) {
        _availableDates.add(date);
      }
      if (_availableDates.length >= 10) break;
    }
  }

  Future<void> _saveBookingToFirebase() async {
    if (_selectedTimeIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى اختيار الوقت")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final date = _availableDates[_selectedDateIndex];
      final time = _availableTimes[_selectedTimeIndex];

      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user?.uid,
        'userEmail': user?.email,
        'doctorName': widget.doctor['name'],
        'doctorSpecialty': widget.doctor['specialty'],
        'doctorEmail': widget.doctor['email'],
        'date': DateFormat('yyyy-MM-dd').format(date),
        'day': DateFormat('EEEE').format(date),
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'upcoming',
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryGreen,
          content: Text("تم حجز الموعد مع ${widget.doctor['name']} بنجاح!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_availableDates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_busy, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("عذراً، لا توجد مواعيد متاحة لهذا الطبيب في الوقت الحالي."),
          ],
        ),
      );
    }

    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text("حجز موعد مع ${widget.doctor['name']}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 20),
            const Text("اختر اليوم المتاح",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : Colors.transparent),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('d').format(date),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textDark)),
                          Text(DateFormat('E').format(date),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.textLight)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("اختر الوقت المتاح",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_availableTimes.length, (index) {
                final isSelected = _selectedTimeIndex == index;
                return ChoiceChip(
                  label: Text(_availableTimes[index]),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 12),
                  onSelected: (selected) =>
                      setState(() => _selectedTimeIndex = selected ? index : -1),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _saveBookingToFirebase,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد وحفظ الحجز",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}