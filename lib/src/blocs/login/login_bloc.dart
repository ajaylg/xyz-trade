import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/src/repository/cache_repository.dart';
import 'package:trading_app/src/repository/login_repository.dart';

import '../../models/user_model.dart';
import '../../utils/exception.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ValueNotifier<bool> enableBtn = ValueNotifier<bool>(false);
  User? userData;
  LoginBloc() : super(LoginInitial()) {
    on<AuthUser>(_authUser);
  }

  Future<FutureOr<void>> _authUser(AuthUser event, emit) async {
    try {
      enableBtn.value = false;
      if (event.username.isNotEmpty && event.password.isNotEmpty) {
        emit(LoginLoading());
        Map<String, dynamic> request = {};
        request['username'] = event.username;
        request['password'] = event.password;
        request['expiresInMins'] = 30;
        userData = await LoginRepository().authUser(request);
        if (userData != null) {
          await CacheRepository.saveData('userData', userData!.toJson());
        }
        emit(LoginDone(userData!));
      }
    } on ServiceException catch (ex) {
      enableBtn.value = true;
      emit(LoginFailed()..failureMsg = ex.message);
    }
  }
}
