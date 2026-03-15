// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  static const String id = 'ContactUsPage';

  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  String? subject, message, phoneNumber;

  Future<void> _sendMessageToFirestore(
    String subject,
    String message,
    String phoneNumber,
  ) async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userEmail == null || userId == null) {
      WarrningMessage(context, 'لم يتم العثور على بيانات المستخدم!');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'message': message,
        'phone': phoneNumber,
        'userEmail': userEmail,
        'uid': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      WarrningMessage(context, 'تم إرسال رسالتك بنجاح!');
    } catch (e) {
      print('Error: $e');
      WarrningMessage(context, 'فشل إرسال الرسالة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("اتصل بنا", style: TextStyle(color: Colors.white)),

        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                "إذا كنت تواجه مشكلة، أرسلها لنا وسنساعدك بأسرع وقت.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),

              // رقم الهاتف (إجباري)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (value) {
                  phoneNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (value.length < 10) {
                    return 'الرجاء إدخال رقم هاتف صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Message Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'رسالتك',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                onChanged: (value) {
                  message = value;
                },
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رسالتك';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendMessageToFirestore(
                      subject ?? 'No subject',
                      message ?? 'No message',
                      phoneNumber ?? '', // سيتم تخزين رقم الهاتف
                    ); // تخزين الرسالة في Firestore
                  }
                },
                child: Text('إرسال', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "تابعنا على مواقع التواصل الاجتماعي",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.tiktok),
                    onPressed: () {
                      _launchURL(
                        'https://www.tiktok.com/@k_shoes1?_t=ZS-8yn789uK2a1&_r=1',
                      );
                    },
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebook),
                    onPressed: () {
                      _launchURL(
                        'https://www.facebook.com/share/1FGokZExHr/?mibextid=wwXIfr',
                      );
                    },
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.instagram),
                    onPressed: () {
                      _launchURL(
                        'https://www.instagram.com/k.shoes_iraq?igsh=MTdiajBrZWswbHd1Yg%3D%3D&utm_source=qr',
                      );
                    },
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.snapchat),
                    onPressed: () {
                      _launchURL('https://t.snapchat.com/tbrgOqiK');
                    },
                    iconSize: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
