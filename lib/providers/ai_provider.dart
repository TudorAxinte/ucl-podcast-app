import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/watch_history_entry.dart';

class AiProvider with ChangeNotifier {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _storage;

  AiProvider._internal();

  static final AiProvider _singleton = AiProvider._internal();

  factory AiProvider.instance () {
    return _singleton;
  }

  factory AiProvider(FirebaseAuth auth, FirebaseFirestore storage) {
    _singleton._auth = auth;
    _singleton._storage = storage;
    return _singleton;
  }

  final Set<WatchHistoryEntry> _watchHistory = SplayTreeSet<WatchHistoryEntry>(
    (b, a) => a.eventDate.compareTo(b.eventDate),
  );

  bool _finishedLoading = false;

  bool get finishedLoading => _finishedLoading;

  CollectionReference get _historyRef =>
      _storage.collection("users").doc(_auth.currentUser!.uid).collection("watch_history");

  List<WatchHistoryEntry> get watchHistory => List.from(_watchHistory);

  Future<void> init() async {
    await Future.wait([
      fetchWatchHistory(),
    ]);
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

  Future<void> updateWatchHistory(PodcastEpisode episode, int secondsWatched) async {
    final json = {
      "date": DateTime.now().microsecondsSinceEpoch,
      "episode_id": episode.id,
      "podcast_id": episode.podcast.id,
      "watched_seconds": secondsWatched
    };

    await _historyRef.add(json);
    _watchHistory.add(WatchHistoryEntry.fromJson(json));
    notifyListeners();
  }
}
