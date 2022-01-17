import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../splash_page.dart';

enum Screen { ACCOUNT_LOGIN, ACCOUNT_REGISTER, SOCIAL_LOGIN }

class LoginPage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => LoginPage(),
    );
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scroll = ScrollController();
  final _loading = ValueNotifier(false);
  final _referred = ValueNotifier(false);
  final _referralCode = TextEditingController();
  final _registering = ValueNotifier(false);
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return auth.isUserLoggedIn
            ? SplashScreen()
            : Scaffold(
                backgroundColor: Colors.white,
                body: Loading(
                  loading: _loading,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Flexible(
                              flex: 3,
                              child: Transform(
                                transform: Matrix4.translationValues(
                                  0,
                                  1,
                                  0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0x00FFFFFF),
                                        Theme.of(context).primaryColor,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              )),
                          Flexible(
                            flex: 1,
                            child: Container(color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 200,
                              width: 500,
                              child: Image.asset(
                                "assets/logo_black.png",
                                width: 160,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _registering,
                        builder: (context, registering, child) => registering ? _register(auth) : _login(auth),
                      )
                    ],
                  ),
                ),
              );
      },
    );
  }

  Widget _login(AuthProvider auth) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 20),
                  spreadRadius: -20,
                  blurRadius: 30,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _email,
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 20),
                  spreadRadius: -20,
                  blurRadius: 30,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _password,
                obscureText: true,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 15),
          MaterialButton(
              height: 54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.black,
              child: Text(
                'Sign in',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              disabledColor: Colors.grey,
              onPressed: () {
                if (_email.text.isEmpty || _password.text.isEmpty) {
                  BotToast.showSimpleNotification(title: "Please complete all fields.", duration: Duration(seconds: 2));
                } else {
                  _loading.value = true;
                  auth.signIn(_email.text, _password.text).then((value) {
                    if (auth.currentUser != null) _scroll.dispose();
                    _loading.value = false;
                  }).onError((error, stackTrace) {
                    _loading.value = false;
                    print(error);
                    BotToast.showSimpleNotification(title: error.toString(), duration: Duration(seconds: 4));
                  });
                }
              }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              _registering.value = true;
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(double.maxFinite, 54.0)),
              side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.black, width: 2)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
            ),
            child: Text(
              'Create account',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 5),
          TextButton(
            child: Text(
              'Forgot password?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[100],
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withAlpha(0x20)),
            ),
            onPressed: () => resetPasswordModal(auth, context, size),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _register(AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 20),
                  spreadRadius: -20,
                  blurRadius: 30,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Display name',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 20),
                  spreadRadius: -20,
                  blurRadius: 30,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _email,
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(0, 20),
                  spreadRadius: -20,
                  blurRadius: 30,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _password,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ValueListenableBuilder<bool>(
            valueListenable: _referred,
            builder: (context, referred, child) => Column(
              children: [
                InkWell(
                  onTap: () => _referred.value = !referred,
                  child: Container(
                    child: Row(
                      children: [
                        Icon(referred ? Icons.check_box : Icons.check_box_outline_blank),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'I have a referral code for my account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (referred)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black87,
                          offset: Offset(0, 20),
                          spreadRadius: -20,
                          blurRadius: 30,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _referralCode,
                        textInputAction: TextInputAction.go,
                        decoration: InputDecoration(
                          hintText: 'Referral code',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          MaterialButton(
              height: 54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.black,
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              disabledColor: Colors.grey,
              onPressed: () {
                if (_email.text.isEmpty ||
                    _name.text.isEmpty ||
                    _password.text.isEmpty ||
                    (_referred.value && _referralCode.text.isEmpty)) {
                  BotToast.showSimpleNotification(title: "Please complete all fields.", duration: Duration(seconds: 3));
                } else {
                  _loading.value = true;
                  auth
                      .register(_name.text, _email.text, _password.text,
                          referralCode: _referred.value ? _referralCode.text.toUpperCase() : null)
                      .then((value) {
                    if (auth.currentUser != null) _scroll.dispose();
                    _loading.value = false;
                  }).onError((error, stackTrace) {
                    _loading.value = false;
                    print(error);
                    BotToast.showSimpleNotification(title: error.toString(), duration: Duration(seconds: 4));
                  });
                }
              }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              _registering.value = false;
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(double.maxFinite, 54.0)),
              side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.black, width: 2)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
            ),
            child: Text(
              'Back to sign in',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void resetPasswordModal(AuthProvider auth, BuildContext screenContext, Size size) {
    final ValueNotifier<bool> _valid = ValueNotifier(false);
    final ValueNotifier<bool> _loading = ValueNotifier(false);
    showMaterialModalBottomSheet(
      context: screenContext,
      expand: false,
      enableDrag: false,
      barrierColor: Colors.black.withAlpha(0xCC),
      builder: (modalContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20 + MediaQuery.of(modalContext).viewInsets.bottom),
            child: ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (context, loading, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password reset',
                        style: TextStyle(
                          fontSize: 34,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 40),
                    loading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: StyledProgressBar(color: Theme.of(context).primaryColor),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black87,
                                      offset: Offset(0, 20),
                                      spreadRadius: -20,
                                      blurRadius: 30,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextFormField(
                                    controller: _email,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (input) => _valid.value = input.isNotEmpty,
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              ValueListenableBuilder<bool>(
                                valueListenable: _valid,
                                builder: (context, valid, child) {
                                  return MaterialButton(
                                    height: 54,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledColor: Theme.of(context).primaryColor.withAlpha(50),
                                    color: Theme.of(context).primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      child: Text(
                                        'Send reset email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    onPressed: valid ? () => resetPassword(modalContext, auth, _loading, _email) : null,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                style: ButtonStyle(
                                  overlayColor:
                                      MaterialStateProperty.all(Theme.of(context).primaryColor.withAlpha(0x20)),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void resetPassword(
    BuildContext context,
    AuthProvider auth,
    ValueNotifier<bool> loading,
    TextEditingController email,
  ) {
    loading.value = true;
    auth.requestPasswordReset(email.text).then((value) {
      BotToast.showSimpleNotification(
        title: "Password reset sent to ${email.text}.",
        duration: Duration(seconds: 3),
      );
      email.clear();
      Navigator.of(context).pop();
    }).catchError((error, stackTrace) {
      email.clear();
      loading.value = false;
      if (error is FirebaseException) {
        BotToast.showSimpleNotification(
          title: error.message!,
          duration: Duration(seconds: 2),
        );
      }
    });
  }
}
