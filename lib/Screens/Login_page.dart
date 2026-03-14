import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/Animation/animated_entry.dart';
import 'package:shopping_app/Cubit/os%20cubit/login_cubit.dart';
import 'package:shopping_app/Screens/Home_Page.dart';
import 'package:shopping_app/Screens/Register_page.dart';
import 'package:shopping_app/Widget/Button.dart';
import 'package:shopping_app/Widget/TextField.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shopping_app/Constant.dart';
import 'package:shopping_app/helper/Function.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'Login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formkey = GlobalKey();
  bool _showPassword = false;

  late LoginCubit loginCubit;

  @override
  void initState() {
    super.initState();
    loginCubit = LoginCubit();
    loginCubit.loadUserEmailPassword();
  }

  @override
  void dispose() {
    loginCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider<LoginCubit>(
        create: (_) => loginCubit,
        child: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess && !state.autoLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    isAdmin: state.isAdmin,
                    isSuperAdmin: state.isSuperAdmin,
                  ),
                ),
              );
            }
            if (state is LoginError) {
              WarrningMessage(context, state.message);
            }
            if (state is LoginSuccess && state.autoLogin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(
                    isAdmin: state.isAdmin,
                    isSuperAdmin: state.isSuperAdmin,
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            bool isLoading = state is LoginLoading;
            final cubit = context.read<LoginCubit>();

            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Form(
                key: formkey,
                child: Scaffold(
                  body: Container(
                    decoration: BoxDecoration(gradient: kBackgroundGradient),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: ListView(
                        children: [
                          const SizedBox(height: 75),
                          AnimatedEntry(
                            delayMilliseconds: 100,
                            child: Image.asset(kImageLogo, height: 100),
                          ),
                          const SizedBox(height: 150),
                          AnimatedEntry(
                            delayMilliseconds: 200,
                            child: Text(
                              "Login",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AnimatedEntry(
                            delayMilliseconds: 300,
                            child: CoustomeTextField(
                              TextHelp: 'Email',
                              initialValue: cubit.email,
                              OnChanged: cubit.setEmail,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedEntry(
                            delayMilliseconds: 400,
                            child: CoustomeTextField(
                              obscure: !_showPassword,
                              TextHelp: 'Password',
                              OnChanged: cubit.setPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedEntry(
                            delayMilliseconds: 500,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: cubit.rememberMe,
                                  onChanged: (val) =>
                                      cubit.setRememberMe(val ?? false),
                                  activeColor: Colors.white,
                                  checkColor: kPrimaryColor,
                                ),
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedEntry(
                            delayMilliseconds: 600,
                            child: CoustomeButton(
                              text: 'Login',
                              ontap: () {
                                if (formkey.currentState!.validate()) {
                                  cubit.loginUser();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedEntry(
                            delayMilliseconds: 700,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?  ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RegisterPage.id,
                                    );
                                  },
                                  child: Text(
                                    'Register Now',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 150),
                          Center(
                            child: Text(
                              "نسخة محدودة جدا جدا",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Center(child: Text('v1.0.5')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
