import 'dart:math';
import 'package:flutter/src/widgets/framework.dart';
import 'package:podcasts_app/components/audio/player.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/search_reslut.dart';

class PodcastEpisode implements SearchResult {
  final String id;
  final String title;
  final String audioUrl;
  final String description;
  final String thumbnailUrl;
  final int lengthInSeconds;
  final DateTime releaseDate;
  final Podcast podcast;

  String get durationText => "${(lengthInSeconds / 60).round()} min";

  PodcastEpisode._(
      this.id,
      this.title,
      this.audioUrl,
      this.description,
      this.lengthInSeconds,
      this.thumbnailUrl,
      this.releaseDate,
      this.podcast,
      );

  factory PodcastEpisode.fromJson(Podcast podcast, Map json) => PodcastEpisode._(
    json["id"],
    json["title"],
    json["audio"],
    json["description"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' '),
    json["audio_length_sec"],
    json["thumbnail"],
    DateTime.fromMillisecondsSinceEpoch(json["pub_date_ms"]),
    podcast,
  );

  factory PodcastEpisode.dummy() => PodcastEpisode._(
    "ID",
    "Example episode ${Random().nextInt(100)}",
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3",
    "This is an example episode to test the UI of the application before real data comes in.",
    500,
    "https://encrypted-tbn0.gstatic"
        ".com/images?q=tbn:ANd9GcTkTeMtwIXqtE5u2Ed95BRHdVKBTUQVUgv3iYUULdRDCNCU4d42mk-xN9_h2PsPSVmcK3Q&usqp=CAU",
    DateTime.utc(2022),
    Podcast.dummy(),
  );

  @override
  bool operator ==(Object other) => other is PodcastEpisode && other.title == this.title && other.id == this.id;

  @override
  int get hashCode => super.hashCode + id.hashCode + title.hashCode;

  @override
  String get author => this.podcast.author;

  @override
  Widget get page => PodcastPlayer(this);
}