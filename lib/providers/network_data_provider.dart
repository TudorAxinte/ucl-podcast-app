import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:podcasts_app/util/extensions.dart';
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

  late final Map<String, String> _requestHeader;
  final Map<int, String> _genres = HashMap();
  final Map<String, String> _regions = HashMap();
  final Set<String> _languages = Set();
  final Set<Podcast> _podcasts = HashSet<Podcast>();
  final Map<String, Podcast> _podcastsMap = HashMap();
  final Set<CuratedPlaylist> _curatedPlaylists = HashSet<CuratedPlaylist>();
  final Map<String, CuratedPlaylist> _curatedPlaylistsMap = HashMap();
  final Map<String, PodcastEpisode> _podcastEpisodesMap = HashMap();
  final Set<PodcastEpisode> _podcastEpisodes = SplayTreeSet<PodcastEpisode>(
    (b, a) => a.releaseDate.compareTo(b.releaseDate),
  );

  bool _finishedLoading = false;

  Map<int, String> get genres => Map.from(_genres);

  Map<String, String> get regions => Map.from(_regions);

  List<String> get languages => List.from(_languages);

  List<Podcast> get podcasts => List.from(_podcasts);

  List<PodcastEpisode> get podcastEpisodes => List.from(_podcastEpisodes);

  List<CuratedPlaylist> get playlists => List.from(_curatedPlaylists);

  bool get finishedLoading => _finishedLoading;

  Future<void> init(String apiKey) async {
    _requestHeader = {
      "App": "Podcasting Together",
      "X-ListenAPI-Key": apiKey,
    };

    await Future.wait([
      fetchBestPodcasts(),
      fetchCuratedPlaylists(),
      fetchGeneres(),
      fetchLanguages(),
      fetchRegions(),
    ]);

    _finishedLoading = true;
    notifyListeners();
  }

  Future<void> fetchSearchResults(String query, {String? type}) async {
    if (type != null) query += "&type=$type";
    await http.get(Uri.parse("$apiBaseUrl/search?q=$query"), headers: _requestHeader).then(
      (response) {
        if (response.wasSuccessful) {
          jsonDecode(response.body)["results"].map(
            (resultJson) => _processSearchResult(resultJson),
          );
        } else {
          print("Fetching results failed (${response.statusCode})");
        }
      },
    );
    notifyListeners();
  }

  Future<CuratedPlaylist> generatePlaylistFromKeyword(String keyword) async {
    final apiResponse = await http.get(
      Uri.parse("$apiBaseUrl/search?q=$keyword&&type=podcast"),
      headers: _requestHeader,
    );

    if (!apiResponse.wasSuccessful) throw ("Podcast API error (code:${apiResponse.statusCode}): ${apiResponse.body}");

    return CuratedPlaylist.fromEpisodes(
      keyword.formatAsTitle,
      List<Podcast>.from(
        jsonDecode(apiResponse.body)["results"].map(
          (resultJson) => _createPodcast(resultJson),
        ),
      ),
    );
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
    await http.get(Uri.parse("$apiBaseUrl/typeahead?q=$query"), headers: _requestHeader).then(
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

  Future<void> fetchBestPodcasts({int? genreId, String? region, String? language}) async {
    String query = "/best_podcasts?";
    if (genreId != null) query += "genre_id=$genreId&&";
    if (region != null) query += "publisher_region=$region&&";
    if (language != null) query += "language=$language";
    await http.get(Uri.parse("$apiBaseUrl/$query"), headers: _requestHeader).then((response) {
      if (response.wasSuccessful) {
        jsonDecode(response.body)["podcasts"].forEach(
          (podcastJson) {
            final newPodcast = _createPodcast(podcastJson);
            newPodcast.updateMetadata(podcastJson);
          },
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
    await http.get(Uri.parse("$apiBaseUrl/curated_podcasts?page=$page"), headers: _requestHeader).then((response) {
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
    await http.get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}"), headers: _requestHeader).then((response) {
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
            headers: _requestHeader)
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

  Future<PodcastEpisode> fetchRandomPodcastEpisode() async {
    final response = await http.get(
      Uri.parse("$apiBaseUrl/just_listen"),
      headers: _requestHeader,
    );
    if (!response.wasSuccessful) throw ("Fetching random podcast failed ${response.statusCode}");
    return _createPodcastEpisode(jsonDecode(response.body));
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
        .get(Uri.parse("$apiBaseUrl/podcasts/${podcast.id}/recommendations"), headers: _requestHeader)
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
        .get(Uri.parse("$apiBaseUrl/podcasts/${episode.id}/recommendations"), headers: _requestHeader)
        .then((response) {
      if (response.wasSuccessful) {
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
    await http.get(Uri.parse("$apiBaseUrl/genres?top_level_only=1"), headers: _requestHeader).then((response) {
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
    await http.get(Uri.parse("$apiBaseUrl/regions"), headers: _requestHeader).then((response) {
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
    await http.get(Uri.parse("$apiBaseUrl/languages"), headers: _requestHeader).then((response) {
      if (response.wasSuccessful) {
        _languages.addAll(
          List<String>.from(jsonDecode(response.body)["languages"]),
        );
        _languages.remove("Any language");
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
