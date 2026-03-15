import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  static const String id = 'ChangePasswordpage';

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool isLoading = false;

  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      final credential = EmailAuthProvider.credential(
        email: email!,
        password: oldPassword,
      );

      await user!.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      WarrningMessage(context, '✅ تم تغيير كلمة المرور بنجاح');

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ';
      if (e.code == 'wrong-password') {
        message = '❌ كلمة المرور القديمة غير صحيحة';
      } else if (e.code == 'weak-password') {
        message = '❌ كلمة المرور الجديدة ضعيفة جدًا';
      }

      WarrningMessage(context, message);
    } catch (e) {
      WarrningMessage(context, '❌ خطأ غير متوقع');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildPasswordField({
    required String label,
    required bool obscureText,
    required Function(String) onChanged,
    required FormFieldValidator<String> validator,
    required VoidCallback toggleVisibility,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TextFormField(
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVisibility,
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('تغيير كلمة المرور', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildPasswordField(
                label: 'كلمة المرور القديمة',
                obscureText: !showOldPassword,
                onChanged: (val) => oldPassword = val,
                validator: (val) => val == null || val.isEmpty
                    ? 'أدخل كلمة المرور القديمة'
                    : null,
                toggleVisibility: () =>
                    setState(() => showOldPassword = !showOldPassword),
              ),
              SizedBox(height: 16),
              buildPasswordField(
                label: 'كلمة المرور الجديدة',
                obscureText: !showNewPassword,
                onChanged: (val) => newPassword = val,
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'أدخل كلمة المرور الجديدة';
                  if (val.length < 6) return 'كلمة المرور قصيرة جداً';
                  return null;
                },
                toggleVisibility: () =>
                    setState(() => showNewPassword = !showNewPassword),
              ),
              SizedBox(height: 16),
              buildPasswordField(
                label: 'تأكيد كلمة المرور',
                obscureText: !showConfirmPassword,
                onChanged: (val) => confirmPassword = val,
                validator: (val) {
                  if (val != newPassword) return 'كلمة المرور غير متطابقة';
                  return null;
                },
                toggleVisibility: () =>
                    setState(() => showConfirmPassword = !showConfirmPassword),
              ),
              SizedBox(height: 32),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: changePassword,
                      icon: Icon(Icons.lock, color: Colors.white),
                      label: Text(
                        'تغيير كلمة المرور',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
