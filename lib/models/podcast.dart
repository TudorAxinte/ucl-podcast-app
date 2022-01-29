enum PodcastCategory { BUSINESS, MINDFULNESS, NEWS, TECH }

extension ex on PodcastCategory {
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

class Podcast {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final String country;
  final String publisher;
  final String email;
  final String description;
  final int totalEpisodes;
  final bool explicitContent;
  final DateTime firstEpisodeDate;
  final DateTime lastEpisodeDate;

  final List<PodcastEpisode> _episodes = [];

  List<PodcastEpisode> get episodes => Iterable.generate(20, (e) => PodcastEpisode.dummy()).toList();
  Iterable<Podcast> get related => Iterable.generate(5, (e) => Podcast.dummy());


  Podcast._(this.id, this.title, this.description, this.email, this.country, this.publisher, this.author,
      this.totalEpisodes, this.explicitContent, this.thumbnailUrl, this.firstEpisodeDate, this.lastEpisodeDate);

  void addEpisode(PodcastEpisode episode) => _episodes.add(episode);

  void clearEpisodes() => _episodes.clear();

  factory Podcast.dummy() => Podcast._(
        "ID",
        "Example",
        "This is the description of this example podcast meant to showcase the design of the application and test the "
            "UI.",
        "example@email.com",
        "UK",
        "Publisher",
        "Author",
        20,
        false,
        "https://encrypted-tbn0.gstatic"
            ".com/images?q=tbn:ANd9GcTkTeMtwIXqtE5u2Ed95BRHdVKBTUQVUgv3iYUULdRDCNCU4d42mk-xN9_h2PsPSVmcK3Q&usqp=CAU",
        DateTime.utc(2018),
        DateTime.utc(2022),
      );

  @override
  bool operator ==(Object other) => other is Podcast && other.title == this.title && other.id == this.id;
}

class PodcastEpisode {
  final Podcast podcast = Podcast.dummy();
  final String id;
  final String title;
  final String audioUrl;
  final String description;
  final int lengthInSeconds;
  final DateTime releaseDate;

  String get durationText => "${(lengthInSeconds / 60).round()} min";

  PodcastEpisode._(this.id, this.title, this.audioUrl, this.description, this.lengthInSeconds, this.releaseDate);

  factory PodcastEpisode.dummy() => PodcastEpisode._(
        "ID",
        "Example episode",
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        "This is an example episode to test the UI of the application before real data comes in.",
        500,
        DateTime.utc(2022),
      );

  @override
  bool operator ==(Object other) => other is PodcastEpisode && other.title == this.title && other.id == this.id;
}
