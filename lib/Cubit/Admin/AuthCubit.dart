import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthUpdated extends AuthState {
  final bool isAdmin;
  AuthUpdated(this.isAdmin);
}

class AuthCubit extends Cubit<AuthState> {
  bool _isAdmin = false;

  AuthCubit() : super(AuthInitial());

  bool get isAdmin => _isAdmin;

  void setAdminStatus(bool status) {
    _isAdmin = status;
    emit(AuthUpdated(status));
  }
}
