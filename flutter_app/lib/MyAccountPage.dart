import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// نفس الألوان المستخدمة في باقي التطبيق للتناسق
class AppColors {
  static const Color primaryGreen = Color(0xFF56BA5B); // اللون الأخضر الأساسي
  static const Color textDark = Color(0xFF333333);
  static const Color white = Colors.white;
}

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final _formKey = GlobalKey<FormState>();

  // المتحكمات بالحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedGender; // للجنس (Dropdown)
  String? _email; // للعرض فقط

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // جلب بيانات المستخدم الحالية من الفايربيس
  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _email = user.email; // الإيميل من المصادقة مباشرة

      try {
        // قراءة البيانات الإضافية من Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? '';
          _ageController.text = data['age'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          setState(() {
            _selectedGender = data['gender'];
          });
        }
      } catch (e) {
        // يمكن إضافة رسالة خطأ هنا
        print("Error fetching data: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  // حفظ البيانات في الفايربيس
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // تخزين البيانات في كوليكشن users
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'age': _ageController.text.trim(),
            'phone': _phoneController.text.trim(),
            'gender': _selectedGender,
            'email': _email, // تخزين الإيميل أيضاً كمرجع
            'last_updated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // merge مهم جداً عشان ما يحذف الداتا القديمة (مثل المحادثات)

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        }
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Profile Picture Section ---
              // Stack(
              //   children: [
              //     Container(
              //       width: 100,
              //       height: 100,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.grey.shade100,
              //         border: Border.all(color: Colors.grey.shade300),
              //       ),
              //       child: const Icon(
              //         Icons.person,
              //         size: 60,
              //         color: Colors.grey,
              //       ),
              //     ),
              //     Positioned(
              //       bottom: 0,
              //       right: 0,
              //       child: Container(
              //         padding: const EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           shape: BoxShape.circle,
              //           border: Border.all(color: Colors.grey.shade200),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.1),
              //               blurRadius: 4,
              //             )
              //           ],
              //         ),
              //         child: const Icon(Icons.camera_alt, size: 18, color: AppColors.primaryGreen),
              //       ),
              //     ),
              //   ],
              // ),

              const SizedBox(height: 40),

              // --- Name Field ---
              _buildTextField(
                controller: _nameController,
                label: "Name",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 20),

              // --- Gender Dropdown ---
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Gender",
                  prefixIcon: const Icon(Icons.male, color: Colors.grey),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
                ),
                items: ["Male", "Female"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) => value == null ? "Please select gender" : null,
              ),

              const SizedBox(height: 20),

              // --- Age Field ---
              _buildTextField(
                controller: _ageController,
                label: "Age",
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // --- Phone Field ---
              _buildTextField(
                controller: _phoneController,
                label: "Phone number",
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // --- Email Field (Disabled) ---
              TextFormField(
                initialValue: _email,
                readOnly: true, // ممنوع التعديل
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),

              const SizedBox(height: 50),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget مساعد لإنشاء حقول الإدخال بنفس التصميم
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your $label";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGreen)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}