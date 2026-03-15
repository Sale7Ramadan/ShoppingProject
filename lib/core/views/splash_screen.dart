import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/auth/views/login_page.dart';
import 'package:shopping_app/features/products/views/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool rememberMe = prefs.getBool('remember_me') ?? false;
    bool isAdmin = prefs.getBool('isAdmin') ?? false;
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    await Future.delayed(const Duration(seconds: 2));
    if (rememberMe && email != null && password != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(isAdmin: isAdmin)),
      );
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(gradient: kBackgroundGradient),
        child: Center(child: Image.asset(kImageLogo, width: 150)),
      ),
    );
  }
}
