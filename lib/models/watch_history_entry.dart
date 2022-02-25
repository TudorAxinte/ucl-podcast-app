class WatchHistoryEntry {
  final String podcastId;
  final String episodeId;
  final Duration duration;
  final DateTime eventDate;

  WatchHistoryEntry._(this.podcastId, this.episodeId, this.duration, this.eventDate);

  factory WatchHistoryEntry.fromJson(Map data) => WatchHistoryEntry._(
        data["podcast_id"],
        data["episode_id"],
        Duration(seconds: data["watched_seconds"]),
        DateTime.fromMillisecondsSinceEpoch(data["date"]),
      );
}
