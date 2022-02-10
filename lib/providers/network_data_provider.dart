import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';

extension Ex on http.Response {
  bool get wasSuccessful => this.statusCode == 200;
}

class NetworkDataProvider with ChangeNotifier {
  NetworkDataProvider._internal();

  static final NetworkDataProvider _singleton = NetworkDataProvider._internal();

  factory NetworkDataProvider() {
    return _singleton;
  }

  final String apiBaseUrl = "https://listen-api.listennotes.com/api/v2";

  late final FirebaseRemoteConfig _config;
  late final Map<String, String> requestHeader;

  final Set<Podcast> _podcasts = HashSet<Podcast>();
  final Map<String, Podcast> _podcastsMap = HashMap();
  final Set<CuratedPlaylist> _curatedPlaylists = HashSet<CuratedPlaylist>();
  final Map<String, CuratedPlaylist> _curatedPlaylistsMap = HashMap();
  final Set<PodcastEpisode> _podcastEpisodes =
      SplayTreeSet<PodcastEpisode>((b, a) => a.releaseDate.compareTo(b.releaseDate));
  final Map<String, PodcastEpisode> _podcastEpisodesMap = HashMap();

  bool _finishedLoading = false;

  List<Podcast> get podcasts => List.from(_podcasts);

  List<PodcastEpisode> get podcastEpisodes => List.from(_podcastEpisodes);

  List<CuratedPlaylist> get playlists => List.from(_curatedPlaylists);

  bool get finishedLoading => _finishedLoading;

  Future<void> init(FirebaseRemoteConfig config) async {
    _config = config;
    await _config.fetchAndActivate();

    requestHeader = {
      "App": "Podcasting Together",
      "X-ListenAPI-Key": _config.getString("API_KEY"),
    };

    await Future.wait([fetchBestPodcasts(), fetchCuratedPlaylists()]);

    _finishedLoading = true;
    notifyListeners();
  }

  Future<void> fetchSearchResults(String query, {String? type}) async {
    if (type != null) query += "&type=$type";
    print("searching for $query");
    await http.get(Uri.parse("$apiBaseUrl/search?q=$query"), headers: requestHeader).then(
      (response) {
        if (response.wasSuccessful) {
          jsonDecode(response.body)["results"].forEach(
            (resultJson) => _processSearchResult(resultJson),
          );
        } else {
          print("Fetching results failed (${response.statusCode})");
        }
      },
    );
    notifyListeners();
  }

  void _processSearchResult(Map resultJson) {
    final isPodcast = resultJson["total_episodes"] != null;
    final isEpisode = resultJson["audio"] != null;
    print(resultJson);

    isPodcast
        ? _processPodcastJson(resultJson)
        : isEpisode
            ? _processPodcastEpisode(resultJson)
            : _processCuratedPlaylistJson(resultJson);
  }

  Future<void> fetchBestPodcasts() async {
    await http.get(Uri.parse("$apiBaseUrl/best_podcasts"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["podcasts"].forEach((podcastJson) => _processPodcastJson(podcastJson));
      } else {
        print("Fetching podcasts failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  void _processPodcastJson(Map podcastJson) => addPodcast(Podcast.fromJson(podcastJson));

  Future<void> fetchCuratedPlaylists({int page = 1}) async {
    await http.get(Uri.parse("$apiBaseUrl/curated_podcasts?page=$page"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["curated_lists"].forEach(
          (playlistJson) => _processCuratedPlaylistJson(playlistJson),
        );
      } else {
        print("Fetching playlists failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  void _processCuratedPlaylistJson(Map playlistJson) {
    final CuratedPlaylist playlist = CuratedPlaylist.fromJson(playlistJson);
    addPlaylist(playlist);
    playlistJson["podcasts"].forEach((podcastJson) {
      final Podcast newPodcast = Podcast.fromJson(podcastJson);
      playlist.addPodcast(newPodcast);
      addPodcast(newPodcast);
    });
  }

  Future<void> fetchPodcastDetails(Podcast podcast) async {
    podcast.clearEpisodes();
    await http.get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        _processPodcastDetailsResponse(podcast, jsonDecode(response.body));
      } else {
        print("Fetching podcast details failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Future<void> fetchNextPodcastEpisodes(Podcast podcast) async {
    await http
        .get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}?next_episode_pub_date=${podcast.nextEpisodePubDate!}"),
            headers: requestHeader)
        .then(
      (response) {
        if (response.wasSuccessful) {
          _processPodcastDetailsResponse(podcast, jsonDecode(response.body));
        } else {
          print("Fetching next episodes failed (${response.statusCode})");
        }
      },
    );
    notifyListeners();
  }

  void _processPodcastDetailsResponse(Podcast podcast, Map resultJson) {
    podcast.updateMetadata(resultJson);
    resultJson["episodes"].forEach(
      (episodeJson) => _processPodcastEpisode(episodeJson, podcast: podcast),
    );
  }

  void _processPodcastEpisode(Map resultJson, {Podcast? podcast}) {
    if (podcast == null) {
      podcast = Podcast.fromJson(resultJson["podcast"]);
      addPodcast(podcast);
    }
    final newEpisode = PodcastEpisode.fromJson(podcast, resultJson);
    podcast.addEpisode(newEpisode);
    addEpisode(newEpisode);
  }

  Future<void> fetchPodcastRecommendations(Podcast podcast) async {
    podcast.clearRecommendations();
    await http
        .get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}/recommendations"), headers: requestHeader)
        .then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["recommendations"].forEach((podcastJson) {
          final recommendedPodcast = Podcast.fromJson(podcastJson);
          podcast.addRecommendation(recommendedPodcast);
          addPodcast(recommendedPodcast);
        });
      } else {
        print("Fetching podcast details failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  void addPodcast(Podcast podcast) {
    if (_podcastsMap[podcast.id] == null) {
      _podcasts.add(podcast);
      _podcastsMap[podcast.id] = podcast;
    }
  }

  void addEpisode(PodcastEpisode episode) {
    if (_podcastEpisodesMap[episode.id] == null) {
      _podcastEpisodes.add(episode);
      _podcastEpisodesMap[episode.id] = episode;
    }
  }

  void addPlaylist(CuratedPlaylist playlist) {
    if (_curatedPlaylistsMap[playlist.id] == null) {
      _curatedPlaylists.add(playlist);
      _curatedPlaylistsMap[playlist.id] = playlist;
    }
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
