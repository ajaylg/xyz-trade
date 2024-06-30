part of 'login_bloc.dart';

abstract class LoginEvent {}

class AuthUser extends LoginEvent {
  final String username;
  final String password;
  AuthUser(this.username,this.password);
}
