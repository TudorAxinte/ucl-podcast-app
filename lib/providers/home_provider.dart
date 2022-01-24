import 'package:flutter/material.dart';
import 'package:podcasts_app/screens/home_tabs/dashboard.dart';
import 'package:podcasts_app/screens/home_tabs/library.dart';
import 'package:podcasts_app/screens/home_tabs/settings.dart';

enum HomeScreen { DASHBOARD, LIBRARY, SETTINGS }

extension ex on HomeScreen {
  Widget iconWidget({active = false}) {
    switch (this) {
      case HomeScreen.DASHBOARD:
        return Image.asset(
          "assets/icons/house.png",
          scale: 5,
          color: active ? Colors.black : Colors.black12,
        );
      case HomeScreen.LIBRARY:
        return Image.asset(
          "assets/icons/menu.png",
          scale: 5,
          color: active ? Colors.black : Colors.black12,
        );
      case HomeScreen.SETTINGS:
        return Image.asset(
          "assets/icons/settings.png",
          scale: 5,
          color: active ? Colors.black : Colors.black12,
        );
    }
  }

  Widget get page {
    switch (this) {
      case HomeScreen.DASHBOARD:
        return DashboardPage();
      case HomeScreen.LIBRARY:
        return LibraryPage();
      case HomeScreen.SETTINGS:
        return SettingsPage();
    }
  }

  String get label => this.toString().split(".").last;
}

class HomeProvider with ChangeNotifier {
  HomeScreen _currentPage = HomeScreen.values.first;

  int get currentIndex => HomeScreen.values.indexOf(_currentPage);

  Widget get page => _currentPage.page;

  HomeScreen get tab => _currentPage;

  void switchToPage(HomeScreen screen) {
    _currentPage = screen;
    notifyListeners();
  }

  void switchToPageNumber(int index) {
    _currentPage = HomeScreen.values[index];
    notifyListeners();
  }

  void reset() {
    _currentPage = HomeScreen.values.first;
    notifyListeners();
  }
}
