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

  Podcast._(this.id, this.title, this.author, this.thumbnailUrl);

  factory Podcast.dummy() => Podcast._(
        "ID",
        "Example",
        "Author",
        "https://encrypted-tbn0.gstatic"
            ".com/images?q=tbn:ANd9GcTkTeMtwIXqtE5u2Ed95BRHdVKBTUQVUgv3iYUULdRDCNCU4d42mk-xN9_h2PsPSVmcK3Q&usqp=CAU",
      );
}
