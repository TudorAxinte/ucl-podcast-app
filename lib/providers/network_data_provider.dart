import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/models/podcast.dart';

class NetworkDataProvider with ChangeNotifier {
  NetworkDataProvider._internal();

  static final NetworkDataProvider _singleton = NetworkDataProvider._internal();

  factory NetworkDataProvider() {
    return _singleton;
  }

  final String apiBaseUrl = "https://listen-api.listennotes.com/api/v2";

  late final FirebaseRemoteConfig _config;
  late final Map<String, String> requestHeader;

  List<Podcast> _podcasts = [];

  bool _finishedLoading = false;

  List<Podcast> get podcasts => List.from(_podcasts);

  bool get finishedLoading => _finishedLoading;

  Future<void> init(FirebaseRemoteConfig config) async {
    _config = config;
    await _config.fetchAndActivate();

    requestHeader = {
      "App": "Podcasting Together",
      "X-ListenAPI-Key": _config.getString("API_KEY"),
    };

    await Future.wait([
      fetchBestPodcasts(),
    ]);

    _finishedLoading = true;
    notifyListeners();
  }

  Future<void> fetchBestPodcasts() async {
    await http.get(Uri.parse("$apiBaseUrl/best_podcasts"), headers: requestHeader).then((response) {
      print(response.body);
    });
  }

  void printLong(String? s) {
    if (s == null || s.isEmpty) return;
    const int n = 1000;
    int startIndex = 0;
    int endIndex = n;
    while (startIndex < s.length) {
      if (endIndex > s.length) endIndex = s.length;
      print(s.substring(startIndex, endIndex));
      startIndex += n;
      endIndex = startIndex + n;
    }
  }
}
