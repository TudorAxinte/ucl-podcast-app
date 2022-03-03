class WatchHistoryEntry {
  final String podcastId;
  final String episodeId;
  final String description;
  final int lengthInSeconds;
  final int watchedSeconds;
  final DateTime eventDate;

  double get watchedPercentage => watchedSeconds / lengthInSeconds * 100;

  WatchHistoryEntry._(
      this.podcastId, this.episodeId, this.description, this.lengthInSeconds, this.watchedSeconds, this.eventDate);

  factory WatchHistoryEntry.fromJson(Map data) => WatchHistoryEntry._(
        data["podcast_id"],
        data["episode_id"],
        data["description"],
        data["length_seconds"],
        data["watched_seconds"],
        DateTime.fromMillisecondsSinceEpoch(data["date"]),
      );
}
