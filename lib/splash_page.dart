import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/home.dart';
import 'package:podcasts_app/screens/login.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin<SplashScreen> {
  late final AuthProvider _auth;
  late final NetworkDataProvider _network;

  @override
  void afterFirstLayout(BuildContext context) {
    _routeUser();
  }

  void _routeUser() async {
    _network = Provider.of<NetworkDataProvider>(context, listen: false);
    _auth = Provider.of<AuthProvider>(context, listen: false);

    await _network.init();
    await _auth.init();

    Navigator.of(context).pushReplacement(
      _auth.isUserLoggedIn ? HomePage.route() : LoginPage.route(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
