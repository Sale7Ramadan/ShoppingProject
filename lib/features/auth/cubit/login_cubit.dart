// login_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  String? email;
  String? password;
  bool rememberMe = false;
  bool isAdmin = false;
  bool isSuperAdmin = false;

  Future<void> loadUserEmailPassword() async {
    emit(LoginLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      email = prefs.getString('email');
      password = prefs.getString('password');
      isAdmin = prefs.getBool('isAdmin') ?? false;
      isSuperAdmin = prefs.getBool('isSuperAdmin') ?? false;
      emit(
        LoginSuccess(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
          email: email,
          password: password,
          rememberMe: rememberMe,
          autoLogin: true,
        ),
      );
    } else {
      emit(LoginInitial());
    }
  }

  void setEmail(String val) {
    email = val;
  }

  void setPassword(String val) {
    password = val;
  }

  void setRememberMe(bool val) {
    rememberMe = val;
    emit(LoginRememberMeChanged(rememberMe));
  }

  Future<void> loginUser() async {
    if (email == null || password == null) {
      emit(LoginError('Please enter email and password'));
      return;
    }
    emit(LoginLoading());
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email!, password: password!);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .get();

      isAdmin = false;
      isSuperAdmin = false;

      if (userDoc.exists) {
        isAdmin = userDoc['isAdmin'] ?? false;
        isSuperAdmin = userDoc['isSuperAdmin'] ?? false;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('email', email!);
        await prefs.setString('password', password!);
        await prefs.setBool('isAdmin', isAdmin);
        await prefs.setBool('isSuperAdmin', isSuperAdmin);
      } else {
        await prefs.setBool('remember_me', false);
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.remove('isAdmin');
        await prefs.remove('isSuperAdmin');
      }

      emit(
        LoginSuccess(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
          email: email,
          password: password,
          rememberMe: rememberMe,
          autoLogin: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginError('User Not Found. Sign up?'));
      } else if (e.code == 'wrong-password') {
        emit(LoginError('Wrong password, try again'));
      } else {
        emit(LoginError('Error: ${e.message}'));
      }
    } catch (e) {
      emit(LoginError('Error: $e'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(LoginLoading());
    try {
      await FirebaseAuth.instance.setLanguageCode(
        'ar',
      ); // لجعل الإيميل بالعربية
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      emit(
        LoginInfo(
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginError('لا يوجد حساب مرتبط بهذا البريد.'));
      } else {
        emit(LoginError('حدث خطأ: ${e.message}'));
      }
    } catch (e) {
      emit(LoginError('حدث خطأ غير متوقع: $e'));
    }
  }
}
