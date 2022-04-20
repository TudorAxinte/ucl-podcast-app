import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/screens/home_tabs/library.dart';
import 'package:provider/provider.dart';

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
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        return Scaffold(
          backgroundColor:
              home.page == LibraryPage()
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).backgroundColor,
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: home.page,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  spreadRadius: 15,
                  offset: const Offset(0, 5),
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
                onTap: (index) => home.switchToPageNumber(index),
                items: HomeScreen.values
                    .map((screen) => BottomNavigationBarItem(
                          icon: screen.iconWidget(active: false),
                          activeIcon: screen.iconWidget(active: true),
                          label: screen.label,
                        ))
                    .toList()),
          ),
        );
      },
    );
  }
}
