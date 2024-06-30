import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/src/blocs/login/login_bloc.dart';
import 'package:trading_app/src/blocs/watchlist/watchlist_bloc.dart';
import 'package:trading_app/src/ui/styles/app_colors.dart';
import '../watchlist/watchlist.dart';

class TradeLogin extends StatefulWidget {
  const TradeLogin({super.key});

  @override
  State<TradeLogin> createState() => _TradeLoginState();
}

class _TradeLoginState extends State<TradeLogin> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late LoginBloc loginBloc;
  @override
  void initState() {
    loginBloc = BlocProvider.of<LoginBloc>(context);
    loginBloc.stream.listen(_listener);
    super.initState();
  }

  Future<void> _listener(LoginState state) async {
    if (state is LoginDone) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
              builder: (BuildContext context) => BlocProvider(
                    create: (context) => WatchlistBloc(),
                    child: const WatchListScreen(),
                  )),
          (route) => false);
    } else if (state is LoginFailed) {
      _showToast(context, state.failureMsg ?? "Request Failed",
          isFailure: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 35, right: 35, top: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _logo(),
              const SizedBox(height: 30),
              const Text(
                "Login",
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              _username(),
              const SizedBox(height: 20),
              _password(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ValueListenableBuilder<bool>(
            valueListenable: loginBloc.enableBtn,
            builder: (context, enableBtn, _) {
              return _submitButton(isEnabled: enableBtn);
            }),
      ),
    );
  }

  Widget _logo() {
    return RichText(
        text: const TextSpan(children: [
      TextSpan(
          text: "XYZ",
          style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
              fontStyle: FontStyle.italic)),
      WidgetSpan(
        child: SizedBox(width: 12),
      ),
      TextSpan(
          text: "Trade",
          style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.w400, color: Colors.green)),
    ]));
  }

  Widget _username() {
    return TextFormField(
      controller: _userNameController,
      showCursor: true,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      autofocus: false,
      maxLength: 50,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: 15,
          top: 12,
          bottom: 12,
          right: 10,
        ),
        labelText: "Username",
        floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
        counterText: '',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      onChanged: (value) {
        _validateInput();
      },
    );
  }

  _validateInput() {
    if (_userNameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      loginBloc.enableBtn.value = false;
    } else {
      loginBloc.enableBtn.value = true;
    }
  }

  Widget _password() {
    return TextFormField(
      controller: _passwordController,
      showCursor: true,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      autofocus: false,
      maxLength: 50,
      obscureText: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: 15,
          top: 12,
          bottom: 12,
          right: 10,
        ),
        labelText: "Password",
        floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
        counterText: '',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      onChanged: (value) {
        _validateInput();
      },
    );
  }

  Widget _submitButton({bool isEnabled = true}) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.4),
        ),
        onPressed: isEnabled == true
            ? () {
                if (FocusManager.instance.primaryFocus != null &&
                    FocusManager.instance.primaryFocus!.hasFocus) {
                  FocusManager.instance.primaryFocus!.unfocus();
                }

                loginBloc.add(AuthUser(
                    _userNameController.text, _passwordController.text));
              }
            : null,
        child: const SizedBox(
          width: 250,
          height: 50,
          child: Center(
            child: Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ));
  }

  void _showToast(BuildContext context, String msg, {bool isFailure = false}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isFailure ? AppColors.negativeColor : AppColors.positiveColor,
      ),
    );
  }
}
