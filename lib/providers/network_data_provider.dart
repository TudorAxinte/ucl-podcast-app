import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:podcasts_app/models/podcast.dart';

class NetworkDataProvider with ChangeNotifier {
  NetworkDataProvider._internal();

  static final NetworkDataProvider _singleton = NetworkDataProvider._internal();

  factory NetworkDataProvider() {
    return _singleton;
  }

  final String apiToken = dotenv.get("API_KEY");

  List<Podcast> _podcasts = [];

  bool _finishedLoading = false;

  List<Podcast> get podcasts => List.from(_podcasts);

  bool get finishedLoading => _finishedLoading;

  Future<void> init() async {
    await Future.wait([
      fetchPodcasts(),
    ]);
    _finishedLoading = true;
    notifyListeners();
  }

  Future<void> fetchPodcasts() async {
    await Future.delayed(Duration(seconds: 1));
    _podcasts.addAll(
      Iterable.generate(
        20,
        (e) => Podcast.dummy(),
      ),
    );
  }
}
