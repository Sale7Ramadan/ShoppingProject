part of 'login_cubit.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isAdmin;
  final bool isSuperAdmin;
  final String? email;
  final String? password;
  final bool rememberMe;
  final bool autoLogin;

  LoginSuccess({
    required this.isAdmin,
    required this.isSuperAdmin,
    this.email,
    this.password,
    required this.rememberMe,
    required this.autoLogin,
  });
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginRememberMeChanged extends LoginState {
  final bool rememberMe;
  LoginRememberMeChanged(this.rememberMe);
}

// ✅ الحالة الجديدة
class LoginInfo extends LoginState {
  final String message;
  LoginInfo(this.message);
}
