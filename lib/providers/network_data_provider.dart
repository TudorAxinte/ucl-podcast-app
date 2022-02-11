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

  final Map<int, String> _genres = HashMap();
  final Map<String, String> _regions = HashMap();
  final Set<String> _languages = Set();

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

    await Future.wait([
      fetchBestPodcasts(),
      fetchCuratedPlaylists(),
    ]);

    Future.wait([
      fetchGeneres(),
      fetchLanguages(),
      fetchRegions(),
    ]);

    _finishedLoading = true;
    notifyListeners();
  }

  Future<void> fetchSearchResults(String query, {String? type}) async {
    if (type != null) query += "&type=$type";
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
    isPodcast
        ? _createPodcast(resultJson)
        : isEpisode
            ? _createPodcastEpisode(resultJson)
            : _createCuratedPlaylist(resultJson);
  }

  Future<List<String>> fetchSearchSuggestions(String query) async {
    final List<String> suggestions = [];
    await http.get(Uri.parse("$apiBaseUrl/typeahead?q=$query"), headers: requestHeader).then(
      (response) {
        if (response.wasSuccessful) {
          suggestions.addAll(
            [
              ...jsonDecode(response.body)["terms"].take(10),
            ],
          );
        } else {
          print("Fetching suggestions failed (${response.statusCode})");
        }
      },
    );
    return suggestions;
  }

  Future<void> fetchBestPodcasts() async {
    await http.get(Uri.parse("$apiBaseUrl/best_podcasts"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["podcasts"].forEach(
          (podcastJson) => _createPodcast(podcastJson),
        );
      } else {
        print("Fetching podcasts failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Podcast _createPodcast(Map podcastJson) {
    final Podcast newPodcast = Podcast.fromJson(podcastJson);
    addPodcast(newPodcast);
    return newPodcast;
  }

  Future<void> fetchCuratedPlaylists({int page = 1}) async {
    await http.get(Uri.parse("$apiBaseUrl/curated_podcasts?page=$page"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["curated_lists"].forEach(
          (playlistJson) => _createCuratedPlaylist(playlistJson),
        );
      } else {
        print("Fetching playlists failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  CuratedPlaylist _createCuratedPlaylist(Map playlistJson) {
    final CuratedPlaylist playlist = CuratedPlaylist.fromJson(playlistJson);
    addPlaylist(playlist);
    playlistJson["podcasts"].forEach((podcastJson) {
      final Podcast newPodcast = Podcast.fromJson(podcastJson);
      playlist.addPodcast(newPodcast);
      addPodcast(newPodcast);
    });
    return playlist;
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
      (episodeJson) => _createPodcastEpisode(episodeJson, podcast: podcast),
    );
  }

  PodcastEpisode _createPodcastEpisode(Map resultJson, {Podcast? podcast}) {
    if (podcast == null) {
      podcast = Podcast.fromJson(resultJson["podcast"]);
      addPodcast(podcast);
    }
    final newEpisode = PodcastEpisode.fromJson(podcast, resultJson);
    podcast.addEpisode(newEpisode);
    addEpisode(newEpisode);
    return newEpisode;
  }

  Future<void> fetchPodcastRecommendations(Podcast podcast) async {
    podcast.clearRecommendations();
    await http
        .get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}/recommendations"), headers: requestHeader)
        .then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["recommendations"].forEach(
          (podcastJson) => podcast.addRecommendation(
            _createPodcast(podcastJson),
          ),
        );
      } else {
        print("Fetching podcast details failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Future<void> fetchEpisodeRecommendations(PodcastEpisode episode) async {
    episode.clearRecommendations();
    await http
        .get(Uri.parse("$apiBaseUrl/podcasts/${episode.id}/recommendations"), headers: requestHeader)
        .then((response) {
      if (response.wasSuccessful) {
        print(response.body);
        jsonDecode(response.body)["recommendations"].forEach(
          (episodeJson) => episode.addRecommendation(
            _createPodcastEpisode(episodeJson),
          ),
        );
      } else {
        print("Fetching podcast details failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Future<void> fetchGeneres() async {
    _genres.clear();
    await http.get(Uri.parse("$apiBaseUrl/genres"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["genres"].forEach(
          (genre) => _genres[genre["id"]] = genre["name"],
        );
      } else {
        print("Fetching genres failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Future<void> fetchRegions() async {
    _regions.clear();
    await http.get(Uri.parse("$apiBaseUrl/regions"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        _regions.addAll(
          Map<String, String>.from(jsonDecode(response.body)["regions"]),
        );
      } else {
        print("Fetching regions failed (${response.statusCode})");
      }
    });
    notifyListeners();
  }

  Future<void> fetchLanguages() async {
    _languages.clear();
    await http.get(Uri.parse("$apiBaseUrl/languages"), headers: requestHeader).then((response) {
      if (response.wasSuccessful) {
        _languages.addAll(
          List<String>.from(
            jsonDecode(response.body)["languages"],
          ),
        );
      } else {
        print("Fetching languages failed (${response.statusCode})");
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
