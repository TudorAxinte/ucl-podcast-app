import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/custom_textfield.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../splash_page.dart';
import 'package:floating_bubbles/floating_bubbles.dart';

import 'home.dart';

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
        return Scaffold(
          backgroundColor: Colors.white,
          body: Loading(
            loading: _loading,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FloatingBubbles.alwaysRepeating(
                    noOfBubbles: 45,
                    colorOfBubbles: Colors.blue.withAlpha(30),
                    sizeFactor: 0.2,
                    opacity: 70,
                    paintingStyle: PaintingStyle.fill,
                    strokeWidth: 8,
                    shape: BubbleShape.circle,
                  ),
                ),
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
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Transform(
                                transform: Matrix4.translationValues(
                                  0,
                                  25,
                                  0,
                                ),
                                child: Text(
                                  "Podcasting",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              Text(
                                "Together",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Pacifico",
                                  fontSize: 70,
                                ),
                              ),
                            ],
                          )),
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
          CustomTextField(
            _email,
            "Email",
            icon: Icons.email,
          ),
          CustomTextField(
            _password,
            "Password",
            icon: Icons.lock,
          ),
          const SizedBox(height: 15),
          MaterialButton(
              height: 55,
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
                    _loading.value = false;
                    Navigator.of(context).pushReplacement(HomePage.route());
                  }).onError((error, stackTrace) {
                    _loading.value = false;
                    print(error);
                    BotToast.showSimpleNotification(title: error.toString(), duration: Duration(seconds: 4));
                  });
                }
              }),
          const SizedBox(height: 15),
          MaterialButton(
              height: 55,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/google.png",
                    scale: 5,
                  ),
                  Spacer(),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              disabledColor: Colors.grey,
              onPressed: () {
                _loading.value = true;
                auth.signInGoogle().then((value) {
                  _loading.value = false;
                  Navigator.of(context).pushReplacement(HomePage.route());
                }).onError((error, stackTrace) {
                  _loading.value = false;
                });
              }),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              _registering.value = true;
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(Size(double.maxFinite, 54.0)),
              side: MaterialStateProperty.all<BorderSide>(BorderSide(color: Colors.black54, width: 2)),
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
          CustomTextField(
            _email,
            "Email",
            icon: Icons.email,
          ),
          CustomTextField(
            _name,
            "Username",
            icon: Icons.person,
          ),
          CustomTextField(
            _password,
            "Password",
            icon: Icons.lock,
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
                    _loading.value = false;
                    Navigator.of(context).pushReplacement(HomePage.route());
                  }).onError((error, stackTrace) {
                    _loading.value = false;
                    print(error);
                    BotToast.showSimpleNotification(title: error.toString(), duration: Duration(seconds: 4));
                  });
                }
              }),
          TextButton(
            child: Text(
              'Back to sign in',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[100],
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withAlpha(0x20)),
            ),
            onPressed: () => _registering.value = false,
          ),
          const SizedBox(height: 50),
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
                      alignment: Alignment.center,
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
                    const SizedBox(height: 20),
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
                              CustomTextField(
                                _email,
                                "Email",
                                icon: Icons.email,
                              ),
                              const SizedBox(height: 20),
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
