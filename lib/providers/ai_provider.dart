import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/watch_history_entry.dart';
import 'package:http/http.dart' as http;

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

  final Set<CuratedPlaylist> _recommendedPlaylists = HashSet<CuratedPlaylist>();
  final Set<WatchHistoryEntry> _watchHistory = SplayTreeSet<WatchHistoryEntry>(
    (b, a) => a.eventDate.compareTo(b.eventDate),
  );

  bool _finishedLoading = false;

  bool get finishedLoading => _finishedLoading;

  List<CuratedPlaylist> get playlists => List.from(_recommendedPlaylists);

  CollectionReference get _historyRef =>
      _storage.collection("users").doc(_auth.currentUser!.uid).collection("watch_history");

  List<WatchHistoryEntry> get watchHistory => List.from(_watchHistory);

  Future<void> init(String watsonApiKey) async {
    _requestHeader = {
      "Authorization": "Basic ${base64Encode(utf8.encode('apikey:${watsonApiKey}'))}",
      "Content-Type": "application/json",
    };
    _finishedLoading = true;
  }

  Future<void> fetchWatchHistory() async {
    _watchHistory.clear();
    await _historyRef.get().then((value) => {
          value.docs.forEach(
            (element) => _watchHistory.add(
              WatchHistoryEntry.fromJson(
                element.data() as Map,
              ),
            ),
          )
        });
    notifyListeners();
  }

  Future<void> generateWatsonNluRecommendations() async {
    final data = {
      "text": mergedWatchHistory,
      "features": {
        "categories": {"limit": 5},
        "summarization": {
          "limit": 3,
        }
      }
    };

    await http
        .post(
      Uri.parse("$watsonUrl/v1/analyze?version=2021-08-01"),
      headers: _requestHeader,
      body: jsonEncode(data),
    )
        .then((value) {
      print(value.body);
    });
    notifyListeners();
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
    _watchHistory.add(WatchHistoryEntry.fromJson(json));
    notifyListeners();
  }

  String get mergedWatchHistory {
    String mergedWatchHistory = "";
    _watchHistory.forEach((entry) {
      if (entry.watchedPercentage > -1) mergedWatchHistory += entry.description;
    });
    return mergedWatchHistory;
  }
}
