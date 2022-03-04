import 'package:flutter/src/widgets/framework.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/search_result.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/playlist_viewer.dart';
import 'package:podcasts_app/util/extensions.dart';

class CuratedPlaylist implements SearchResult {
  final String id;
  final String title;
  final String? description;
  final String? sourceUrl;
  final Set<Podcast> _podcasts = {};

  CuratedPlaylist._(this.id, this.title, {this.description, this.sourceUrl});

  List<Podcast> get podcasts => List.from(_podcasts);

  void addPodcast(Podcast podcast) => _podcasts.add(podcast);

  void clearPodcasts() => _podcasts.clear();

  factory CuratedPlaylist.fromEpisodes(String title, List<Podcast> podcasts) {
    final CuratedPlaylist playlist = CuratedPlaylist._(title.hashCode.toString(), title);
    podcasts.forEach((podcast) => playlist.addPodcast(podcast));
    return playlist;
  }

  factory CuratedPlaylist.fromJson(Map json) => CuratedPlaylist._(
        json["id"],
        json["title"] ?? json["title_original"],
        description: json["description"] ?? json["description_original"],
        sourceUrl: json["source_domain"],
      );

  @override
  String get author => sourceUrl?.replaceAll("www.", "").capitalize() ?? "";

  @override
  String get thumbnailUrl => _podcasts.first.thumbnailUrl;

  @override
  Widget get page => CuratedPlaylistPage(this);

  @override
  int get hashCode => id.hashCode + title.hashCode;

  @override
  bool operator ==(Object other) => other is CuratedPlaylist && other.title == this.title && other.id == this.id;
}
