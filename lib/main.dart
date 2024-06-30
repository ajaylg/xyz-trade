import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/src/blocs/login/login_bloc.dart';
import 'package:trading_app/src/repository/cache_repository.dart';

import 'src/ui/screens/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await RealTimeDataHandler().startReceivingData();
  }
  await CacheRepository.init();
  runApp(const XYZTrade());
}

class XYZTrade extends StatelessWidget {
  const XYZTrade({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XYZ Trade',
      theme: ThemeData(),
      home: BlocProvider(
        create: (context) => LoginBloc(),
        child: const TradeLogin(),
      ),
    );
  }
}

class RealTimeDataHandler {
  static const platform = MethodChannel('com.example.trading_app/realtime');
  Future<void> startReceivingData() async {
    try {
      await platform.invokeMethod('startReceivingData');
    } on PlatformException catch (e) {
      print("Failed to start receiving data: '${e.message}'.");
    }
  }
}
