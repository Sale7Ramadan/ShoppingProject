import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/helper/Function.dart';

class ManageAdminsPage extends StatefulWidget {
  const ManageAdminsPage({super.key});
  static const String id = 'ManageAdminPage';

  @override
  _ManageAdminsPageState createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  bool isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return; // ✅ تحقق من أن الواجهة لا تزال موجودة

      setState(() {
        isSuperAdmin = doc.data()?['isSuperAdmin'] ?? false;
      });
    }
  }

  Future<DocumentSnapshot?> _getUserByEmail(String email) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _toggleAdminStatus(String userId, bool currentStatus) async {
    try {
      if (!isSuperAdmin) {
        if (!mounted) return;
        WarrningMessage(context, 'ليس لديك صلاحية لتغيير هذه الحالة');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isAdmin': !currentStatus,
      });

      if (!mounted) return;
      WarrningMessage(context, 'تم تحديث حالة الأدمن');
    } catch (e) {
      if (!mounted) return;
      WarrningMessage(context, 'حدث خطأ في تحديث حالة الأدمن');
    }
  }

  Future<void> _addAdmin(String email) async {
    if (!isSuperAdmin) {
      if (!mounted) return;
      WarrningMessage(context, 'ليس لديك صلاحية لإضافة أدمن');
      return;
    }

    var userDoc = await _getUserByEmail(email);
    if (userDoc != null) {
      bool isAdmin = userDoc['isAdmin'] ?? false;

      await _toggleAdminStatus(userDoc.id, isAdmin);
    } else {
      if (!mounted) return;
      setState(() {
        _emailError = "البريد الإلكتروني غير موجود!";
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الأدمن', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل البريد الإلكتروني لاضافة أدمن:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                errorText: _emailError,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addAdmin(_emailController.text.trim());
              },
              child: Text('إضافة أدمن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('isAdmin', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('لا يوجد أدمنز حالياً'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var user = docs[index];
                      String userName =
                          '${user['first_name']} ${user['last_name']}';
                      String userEmail = user['email'] ?? 'غير معروف';
                      bool isAdmin = user['isAdmin'] ?? false;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(userName),
                          subtitle: Text('البريد الإلكتروني: $userEmail'),
                          trailing: IconButton(
                            icon: Icon(
                              isAdmin ? Icons.block : Icons.check_circle,
                            ),
                            onPressed: () {
                              _toggleAdminStatus(user.id, isAdmin);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
