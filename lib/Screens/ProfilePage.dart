import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/Screens/AddressEntryPage.dart';
import 'package:shopping_app/Screens/ChangePasswordPage.dart';
import 'package:shopping_app/Screens/Login_page.dart';

class ProfilePage extends StatefulWidget {
  static const String id = 'profile_page';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKeyName = GlobalKey<FormState>();
  final _formKeyPhone = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  String firstName = '';
  String lastName = '';
  String phone = '';
  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool isEditingName = false;
  bool isEditingPhone = false;
  bool isEditingPassword = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();

      if (data != null) {
        setState(() {
          firstName = data['first_name'] ?? '';
          lastName = data['last_name'] ?? '';
          phone = data['phone'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء جلب البيانات')));
    }
  }

  Future<void> updateName() async {
    if (_formKeyName.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'first_name': firstName, 'last_name': lastName});

        setState(() => isEditingName = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم تحديث الاسم بنجاح')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء تحديث الاسم')));
      }
    }
  }

  Future<void> updatePhone() async {
    if (_formKeyPhone.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'phone': phone});

        setState(() => isEditingPhone = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم تحديث رقم الهاتف')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحديث رقم الهاتف')),
        );
      }
    }
  }

  Future<bool> updatePassword() async {
    if (_formKeyPassword.currentState!.validate()) {
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: user!.email!,
              password: oldPassword,
            );

        await userCredential.user!.updatePassword(newPassword);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));

        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('كلمة المرور القديمة غير صحيحة')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء تغيير كلمة المرور')),
          );
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة الاسم
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: kPrimaryColor),
                            SizedBox(width: 8),
                            Text(
                              'الاسم',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => isEditingName = !isEditingName),
                          icon: Icon(
                            isEditingName ? Icons.cancel : Icons.edit,
                            color: kPrimaryColor,
                          ),
                          label: Text(
                            isEditingName ? 'إلغاء' : 'تعديل',
                            style: TextStyle(color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    isEditingName
                        ? Form(
                            key: _formKeyName,
                            child: Column(
                              children: [
                                TextFormField(
                                  initialValue: firstName,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم الأول',
                                  ),
                                  onChanged: (val) => firstName = val,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'أدخل الاسم الأول'
                                      : null,
                                ),
                                SizedBox(height: 12),
                                TextFormField(
                                  initialValue: lastName,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم الأخير',
                                  ),
                                  onChanged: (val) => lastName = val,
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'أدخل الاسم الأخير'
                                      : null,
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: updateName,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                    ),
                                    child: Text(
                                      'حفظ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            '$firstName $lastName',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // بطاقة البريد الإلكتروني
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.email, color: kPrimaryColor),
                title: Text(
                  'البريد الإلكتروني',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user!.email ?? ''),
              ),
            ),

            SizedBox(height: 20),

            // بطاقة رقم الهاتف
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone, color: kPrimaryColor),
                            SizedBox(width: 8),
                            Text(
                              'رقم الهاتف',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => isEditingPhone = !isEditingPhone),
                          icon: Icon(
                            isEditingPhone ? Icons.cancel : Icons.edit,
                            color: kPrimaryColor,
                          ),
                          label: Text(
                            isEditingPhone ? 'إلغاء' : 'تعديل',
                            style: TextStyle(color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    isEditingPhone
                        ? Form(
                            key: _formKeyPhone,
                            child: TextFormField(
                              initialValue: phone,
                              decoration: InputDecoration(
                                labelText: 'أدخل رقم الهاتف',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: (val) => phone = val,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'أدخل رقم الهاتف';
                                }
                                final phoneRegex = RegExp(r'^\+?\d{8,15}$');
                                if (!phoneRegex.hasMatch(val)) {
                                  return 'رقم هاتف غير صالح';
                                }
                                return null;
                              },
                            ),
                          )
                        : Text(
                            phone.isEmpty ? 'لم يتم إدخال رقم الهاتف' : phone,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                    if (isEditingPhone)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: updatePhone,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            child: Text(
                              'حفظ',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, ChangePasswordPage.id);
              },
              icon: Icon(Icons.lock, color: Colors.white),
              label: Text(
                'تغيير كلمة المرور',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AddressEntryPage.id);
              },
              icon: Icon(Icons.house, color: Colors.white),
              label: Text(
                'تغيير العنوان',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, LoginPage.id);
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 50),
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
}
