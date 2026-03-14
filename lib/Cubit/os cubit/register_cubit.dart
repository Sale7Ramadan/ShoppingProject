import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<void> registerUser({
    required String fName,
    required String lName,
    required String email,
    required String password,
    String? phone,
    bool rememberMe = false,
  }) async {
    emit(RegisterLoading());

    try {
      // إنشاء مستخدم في Firebase Auth
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = user.user!.uid;

      // حفظ بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'first_name': fName,
        'last_name': lName,
        'email': email,
        'isAdmin': false,
        'isSuperAdmin': false,
        'created_at': DateTime.now(),
        'phone': phone,
      });

      // حفظ بيانات في SharedPreferences إذا اختار RememberMe
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setBool('isAdmin', false);
        await prefs.setBool('isSuperAdmin', false);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', false);
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.remove('isAdmin');
        await prefs.remove('isSuperAdmin');
      }

      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(RegisterFailure(message: e.code));
    } catch (e) {
      emit(RegisterFailure(message: e.toString()));
    }
  }
}
