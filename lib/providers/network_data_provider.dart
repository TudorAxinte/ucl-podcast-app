import 'dart:async';
import 'package:flutter/cupertino.dart';

class NetworkDataProvider with ChangeNotifier {
  NetworkDataProvider._internal();

  static final NetworkDataProvider _singleton = NetworkDataProvider._internal();

  factory NetworkDataProvider() {
    return _singleton;
  }

  Future<void> init() async {}
}
