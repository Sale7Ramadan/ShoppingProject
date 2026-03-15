import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/core/animations/animated_entry.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/auth/cubit/register_cubit.dart';
import 'package:shopping_app/features/products/views/home_page.dart';
import 'package:shopping_app/core/widgets/button.dart';
import 'package:shopping_app/core/widgets/text_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shopping_app/core/helpers/app_functions.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  static const String id = 'Register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? fName, lName, email, password, phone;
  bool rememberMe = false;
  bool _showPassword = false;
  GlobalKey<FormState> formkey = GlobalKey();

  void handleRememberMe(bool? value) {
    setState(() {
      rememberMe = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider(
        create: (_) => RegisterCubit(),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterFailure) {
              String message = '';
              if (state.message == 'weak-password') {
                message = 'The password provided is too weak';
              } else if (state.message == 'email-already-in-use') {
                message = 'Email Already In Use';
              } else {
                message = state.message;
              }
              WarrningMessage(context, message);
            } else if (state is RegisterSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage(isAdmin: false)),
              );
            }
          },
          builder: (context, state) {
            bool isLoading = state is RegisterLoading;

            return ModalProgressHUD(
              inAsyncCall: isLoading,
              child: Scaffold(
                body: Container(
                  decoration: BoxDecoration(gradient: kBackgroundGradient),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Form(
                      key: formkey,
                      child: ListView(
                        children: [
                          const SizedBox(height: 75),
                          Image.asset(kImageLogo, height: 100),
                          const SizedBox(height: 150),
                          AnimatedEntry(
                            delayMilliseconds: 100,
                            child: Text(
                              "Register",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 200,
                            child: CoustomeTextField(
                              TextHelp: 'First Name',
                              OnChanged: (data) => fName = data,
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 300,
                            child: CoustomeTextField(
                              TextHelp: 'Last Name',
                              OnChanged: (data) => lName = data,
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 400,
                            child: CoustomeTextField(
                              TextHelp: 'Email',
                              OnChanged: (data) => email = data,
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 500,
                            child: CoustomeTextField(
                              obscure: !_showPassword,
                              TextHelp: 'Password',
                              OnChanged: (data) => password = data,
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
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 600,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: handleRememberMe,
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
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 700,
                            child: CoustomeButton(
                              text: 'Register',
                              ontap: () {
                                if (formkey.currentState!.validate()) {
                                  if (fName == null ||
                                      lName == null ||
                                      email == null ||
                                      password == null) {
                                    WarrningMessage(
                                      context,
                                      'Please fill all fields',
                                    );
                                    return;
                                  }
                                  context.read<RegisterCubit>().registerUser(
                                    fName: fName!,
                                    lName: lName!,
                                    email: email!,
                                    password: password!,
                                    phone: phone,
                                    rememberMe: rememberMe,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          AnimatedEntry(
                            delayMilliseconds: 800,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'I Already have an account',
                                  style: TextStyle(color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    ' Login Now',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
