import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:provider/provider.dart';
import '../splash_page.dart';

class HomePage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => HomePage(),
    );
  }

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, AuthProvider>(
      builder: (context, home, auth, child) {
        final selectedColor = Theme.of(context).primaryColor;
        final normalColor = Colors.grey;
        final bgColor = Colors.white;

        return auth.isUserLoggedIn
            ? SplashScreen()
            : Scaffold(
                backgroundColor: bgColor,
                body: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: home.screen,
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: home.tab.index,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    onTap: (index) => home.switchPage(index),
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.local_offer, color: normalColor!),
                        activeIcon: Icon(Icons.local_offer, color: selectedColor!),
                        label: 'Brands',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          "assets/icons/supergroups.png",
                          scale: 11,
                          color: normalColor!,
                        ),
                        activeIcon: Image.asset(
                          "assets/icons/supergroups.png",
                          scale: 11,
                          color: selectedColor!,
                        ),
                        label: 'Groups',
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          "assets/icons/maps.png",
                          scale: 8,
                          color: normalColor!,
                        ),
                        activeIcon: Image.asset(
                          "assets/icons/maps.png",
                          scale: 8,
                          color: selectedColor!,
                        ),
                        label: 'Map',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_box_outlined, color: normalColor!),
                        activeIcon: Icon(Icons.account_box_outlined, color: selectedColor!),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
