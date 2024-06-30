part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginDone extends LoginState {
  User userData;
  LoginDone(this.userData);
}

class LoginFailed extends LoginState {
  String? failureMsg;
  LoginFailed({this.failureMsg});
}
