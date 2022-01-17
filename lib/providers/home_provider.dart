import 'package:flutter/material.dart';

enum TabScreen { HOME, PROFILE }

class HomeProvider with ChangeNotifier {
  List<Widget> _screens = [];

  Widget get screen => Text("hello"); //_screens[_currentIndex];

  int _currentIndex = 0;

  TabScreen get tab => TabScreen.values[_currentIndex];

  HomeProvider() {
    _screens = [];
  }

  void switchPage(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    notifyListeners();
  }
}
