import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/auth/views/change_password_page.dart';
import 'package:shopping_app/features/auth/views/login_page.dart';
import 'package:shopping_app/features/cart/views/address_entry_page.dart';
import 'package:shopping_app/features/profile/widgets/profile_components.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final _nameFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String phone = '';
  bool isEditingName = false;
  bool isEditingPhone = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (_user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        firstName = data['first_name'] ?? '';
        lastName = data['last_name'] ?? '';
        phone = data['phone'] ?? '';
      }
    } catch (_) {
      _showMessage('حدث خطأ أثناء جلب البيانات');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> updateName() async {
    if (!_nameFormKey.currentState!.validate() || _user == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(_user.uid).update({
        'first_name': firstName,
        'last_name': lastName,
      });

      setState(() => isEditingName = false);
      _showMessage('تم تحديث الاسم بنجاح');
    } catch (_) {
      _showMessage('حدث خطأ أثناء تحديث الاسم');
    }
  }

  Future<void> updatePhone() async {
    if (!_phoneFormKey.currentState!.validate() || _user == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({'phone': phone});

      setState(() => isEditingPhone = false);
      _showMessage('تم تحديث رقم الهاتف');
    } catch (_) {
      _showMessage('حدث خطأ أثناء تحديث رقم الهاتف');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushReplacementNamed(context, LoginPage.id);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNameCard(),
                  const SizedBox(height: 20),
                  _buildEmailCard(),
                  const SizedBox(height: 20),
                  _buildPhoneCard(),
                  const SizedBox(height: 30),
                  ProfilePrimaryActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ChangePasswordPage.id);
                    },
                    icon: Icons.lock,
                    text: 'تغيير كلمة المرور',
                  ),
                  const SizedBox(height: 20),
                  ProfilePrimaryActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AddressEntryPage.id);
                    },
                    icon: Icons.house,
                    text: 'تغيير العنوان',
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNameCard() {
    return ProfileCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionHeader(
            icon: Icons.person,
            title: 'الاسم',
            isEditing: isEditingName,
            onToggleEdit: () {
              setState(() => isEditingName = !isEditingName);
            },
          ),
          const SizedBox(height: 10),
          if (isEditingName)
            Form(
              key: _nameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: firstName,
                    decoration: const InputDecoration(labelText: 'الاسم الأول'),
                    onChanged: (value) => firstName = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'أدخل الاسم الأول' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: lastName,
                    decoration: const InputDecoration(labelText: 'الاسم الأخير'),
                    onChanged: (value) => lastName = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'أدخل الاسم الأخير' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateName,
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                      child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              '$firstName $lastName',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.email, color: kPrimaryColor),
        title: const Text(
          'البريد الإلكتروني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_user?.email ?? ''),
      ),
    );
  }

  Widget _buildPhoneCard() {
    return ProfileCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionHeader(
            icon: Icons.phone,
            title: 'رقم الهاتف',
            isEditing: isEditingPhone,
            onToggleEdit: () {
              setState(() => isEditingPhone = !isEditingPhone);
            },
          ),
          const SizedBox(height: 10),
          if (isEditingPhone)
            Form(
              key: _phoneFormKey,
              child: TextFormField(
                initialValue: phone,
                decoration: const InputDecoration(
                  labelText: 'أدخل رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => phone = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل رقم الهاتف';
                  }
                  final phoneRegex = RegExp(r'^\+?\d{8,15}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'رقم هاتف غير صالح';
                  }
                  return null;
                },
              ),
            )
          else
            Text(
              phone.isEmpty ? 'لم يتم إدخال رقم الهاتف' : phone,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          if (isEditingPhone)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updatePhone,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
