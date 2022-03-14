import 'dart:collection';
import 'dart:convert';
import 'package:podcasts_app/models/app_user.dart';
import 'package:podcasts_app/util/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/watch_history_entry.dart';
import 'package:http/http.dart' as http;
import 'package:podcasts_app/providers/network_data_provider.dart';

class AiProvider with ChangeNotifier {
  AiProvider._internal();

  static final AiProvider _singleton = AiProvider._internal();

  factory AiProvider.instance() {
    return _singleton;
  }

  factory AiProvider(FirebaseAuth auth, FirebaseFirestore storage) {
    _singleton._auth = auth;
    _singleton._storage = storage;
    return _singleton;
  }

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _storage;
  late final Map<String, String> _requestHeader;
  final String watsonUrl = "https://api.eu-gb.natural-language-understanding.watson.cloud.ibm"
      ".com/instances/dc5e8eb4-6f5d-4cfd-ac8b-c5ba2d40f3f7";
  final NetworkDataProvider data = NetworkDataProvider();
  final Set<CuratedPlaylist> _recommendedPlaylists = HashSet<CuratedPlaylist>();

  List<CuratedPlaylist> get playlists => List.from(_recommendedPlaylists);

  CollectionReference get _historyRef =>
      _storage.collection("users").doc(_auth.currentUser!.uid).collection("watch_history");

  Future<void> init(String watsonApiKey) async {
    _requestHeader = {
      "Authorization": "Basic ${base64Encode(utf8.encode('apikey:${watsonApiKey}'))}",
      "Content-Type": "application/json",
    };
  }

  Future<String> generateWatsonNluInput(List<AppUser> userPool) async {
    final Set<WatchHistoryEntry> watchHistory = SplayTreeSet<WatchHistoryEntry>(
      (b, a) => a.eventDate.compareTo(b.eventDate),
    );
    Future<void> updateWatchHistory(AppUser user) async => watchHistory.addAll(await fetchWatchHistory(user));
    await Future.wait(userPool.map((user) => updateWatchHistory(user)));
    return watchHistory.map((entry) => entrySummary(entry)).reduce((a, b) => a + b);
  }

  Future<Set<WatchHistoryEntry>> fetchWatchHistory(AppUser user) async {
    final ref = _storage.collection("users").doc(user.id).collection("watch_history");
    final Set<WatchHistoryEntry> _watchHistory = SplayTreeSet<WatchHistoryEntry>(
      (b, a) => a.eventDate.compareTo(b.eventDate),
    );
    await ref.get().then((value) => {
          value.docs.forEach(
            (element) => _watchHistory.add(
              WatchHistoryEntry.fromJson(
                element.data(),
              ),
            ),
          )
        });
    return _watchHistory;
  }

  Future<void> generateWatsonNluRecommendations(String input) async {
    _recommendedPlaylists.clear();
    final data = {
      "text": input,
      "features": {
        "categories": {"limit": 5},
        "summarization": {
          "limit": 3,
        }
      }
    };

    final watsonResponse = await http.post(
      Uri.parse("$watsonUrl/v1/analyze?version=2021-08-01"),
      headers: _requestHeader,
      body: jsonEncode(data),
    );

    if (watsonResponse.wasSuccessful) {
      final List<String> watsonNlpResults = List<String>.from(
        jsonDecode(watsonResponse.body)["categories"].map(
          (cat) => cat["label"].split("/").last,
        ),
      );

      /*
       Sending requests one at a time, delayed by 600ms, as the Podcasts API free tier plan
       limits requests to 2/sec. Upon purchasing a paid plan, concurrent requests here would
       cut recommendation loading times by ~90%.
      */
      await Future.delayed(Duration(seconds: 2));
      await Future.forEach(
        watsonNlpResults,
        (result) => Future.delayed(
          Duration(milliseconds: 1000),
          () => generateRecommendationFromKeyword(result as String),
        ),
      );
    } else {
      print("Watson error: ${watsonResponse.body}");
    }

    notifyListeners();
  }

  Future<void> generateRecommendationFromKeyword(String keyword) async {
    await data.generatePlaylistFromKeyword(keyword).then(
      (playlist) {
        if (playlist.podcasts.isNotEmpty) _recommendedPlaylists.add(playlist);
      },
    );
  }

  Future<void> updateWatchHistory(PodcastEpisode episode, int secondsWatched) async {
    final json = {
      "date": DateTime.now().microsecondsSinceEpoch,
      "episode_id": episode.id,
      "podcast_id": episode.podcast.id,
      "description": episode.description,
      "length_seconds": episode.lengthInSeconds,
      "watched_seconds": secondsWatched
    };

    await _historyRef.add(json);
    notifyListeners();
  }

  String entrySummary(WatchHistoryEntry entry) => entry.description.preparedForNlp;

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
