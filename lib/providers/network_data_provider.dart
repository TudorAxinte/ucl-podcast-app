import 'dart:async';
import 'package:flutter/cupertino.dart';

class NetworkDataProvider with ChangeNotifier {
  NetworkDataProvider._internal();
  static final NetworkDataProvider _singleton = NetworkDataProvider._internal();
  factory NetworkDataProvider() {
    return _singleton;
  }

  bool _finishedLoading = false;

  bool get finishedLoading => _finishedLoading;

  Future<void> init() async {
    await Future.delayed(Duration(seconds: 1));
    _finishedLoading = true;
    notifyListeners();
  }
}
