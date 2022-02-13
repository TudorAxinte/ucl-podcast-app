import 'dart:collection';

import 'package:flutter/src/widgets/framework.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/search_result.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';

enum PodcastCategory { BUSINESS, MINDFULNESS, NEWS, TECH }

extension Ex on PodcastCategory {
  String get thumbnailPath {
    switch (this) {
      case PodcastCategory.BUSINESS:
        return "assets/business.jpeg";
      case PodcastCategory.MINDFULNESS:
        return "assets/mindfulness.png";
      case PodcastCategory.NEWS:
        return "assets/news.jpeg";
      case PodcastCategory.TECH:
        return "assets/tech.jpeg";
    }
  }

  String get name {
    final name = this.toString().split(".").last;
    return "${name[0].toUpperCase()}${name.substring(1).toLowerCase()}";
  }
}

class Podcast implements SearchResult {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String publisher;

  final Set<int> _genres = HashSet();
  String? _language;
  String? _country;
  String? _description;
  int? _totalEpisodes;
  bool? _explicitContent;
  DateTime? _firstEpisodeDate;
  DateTime? _lastEpisodeDate;

  String? get language => _language;

  String? get country => _country;

  String? get description => _description;

  int? get totalEpisodes => _totalEpisodes;

  bool? get explicitContent => _explicitContent;

  DateTime? get firstEpisodeDate => _firstEpisodeDate;

  DateTime? get lastEpisodeDate => _lastEpisodeDate;

  final Set<Podcast> _related = HashSet<Podcast>();
  final Set<PodcastEpisode> _episodes = SplayTreeSet<PodcastEpisode>(
    (b, a) => a.releaseDate.compareTo(b.releaseDate),
  );

  int? _nextEpisodePubDate;

  int? get nextEpisodePubDate => _nextEpisodePubDate;

  List<int> get genresIds => List.from(_genres);

  List<PodcastEpisode> get episodes => List.from(_episodes);

  Iterable<Podcast> get related => List.from(_related);

  Podcast._(this.id, this.title, this.publisher, this.thumbnailUrl);

  void updateNextEpisodeTimestamp(int newTimestamp) => _nextEpisodePubDate = newTimestamp;

  void addEpisode(PodcastEpisode episode) => _episodes.add(episode);

  void addRecommendation(Podcast podcast) => _related.add(podcast);

  void clearRecommendations() => _related.clear();

  void clearEpisodes() => _episodes.clear();

  void updateMetadata(Map json) {
    _description = json["description"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
    _country = json["country"];
    _language = json["language"];
    _totalEpisodes = json["total_episodes"];
    _explicitContent = json["explicit_content"];
    _nextEpisodePubDate = json["next_episode_pub_date"];
    _firstEpisodeDate = DateTime.fromMillisecondsSinceEpoch(json["earliest_pub_date_ms"]);
    _lastEpisodeDate = DateTime.fromMillisecondsSinceEpoch(json["latest_pub_date_ms"]);
    if (json["genre_ids"] != null) for (int genreId in json["genre_ids"]) _genres.add(genreId);
  }

  factory Podcast.fromJson(Map json) => Podcast._(
        json["id"],
        json["title"] ?? json["title_original"],
        json["publisher"] ?? json["publisher_original"],
        json["thumbnail"],
      );

  factory Podcast.dummy() => Podcast._(
        "ID",
        "Example",
        "Publisher",
        "https://encrypted-tbn0.gstatic"
            ".com/images?q=tbn:ANd9GcTkTeMtwIXqtE5u2Ed95BRHdVKBTUQVUgv3iYUULdRDCNCU4d42mk-xN9_h2PsPSVmcK3Q&usqp=CAU",
      );

  @override
  bool operator ==(Object other) => other is Podcast && other.title == this.title && other.id == this.id;

  @override
  int get hashCode => id.hashCode + title.hashCode;

  @override
  String get author => this.publisher;

  @override
  Widget get page => PodcastViewerPage(this);
}
