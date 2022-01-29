import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/components/cards/episode_card.dart';
import 'package:podcasts_app/components/cards/vertical_podcast_card.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';
import '../util/extensions.dart';

class PodcastViewerPage extends StatelessWidget {
  final Podcast podcast;
  final _loading = ValueNotifier(false);

  PodcastViewerPage(this.podcast);

  void fetchEpisodes() async {
    _loading.value = true;
    await Future.delayed(Duration(seconds: 1));
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    fetchEpisodes();
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          InkResponse(
            child: Icon(
              Icons.clear,
              size: 20,
              color: Colors.black,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 20),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Consumer<NetworkDataProvider>(builder: (_, data, __) {
          final List<PodcastEpisode> episodes = podcast.episodes.take(8).toList();
          return Column(
            children: [
              Container(
                width: size.width,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                color: Theme.of(context).primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      margin: EdgeInsets.only(top: hasNotch ? 60 : 30, bottom: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Stack(children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: podcast.thumbnailUrl,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.white,
                                child: Center(child: SizedProgressCircular()),
                              ),
                              errorWidget: (context, url, error) => SizedBox(),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.75),
                                      Colors.black.withOpacity(0.95),
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(0.0, 1.0),
                                    stops: [0.4, 0.7, 1.0],
                                    tileMode: TileMode.decal),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Text(
                      podcast.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      podcast.author,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () {},
                      child: Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Last episode",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              Transform(
                transform: Matrix4.translationValues(
                  0,
                  -30,
                  0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Episodes",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "View all",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _loading,
                        builder: (context, loading, _) => ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: episodes.length,
                            itemBuilder: (_, index) {
                              final episode = loading ? PodcastEpisode.dummy() : episodes[index];
                              return MaterialButton(
                                onPressed: () {},
                                child: EpisodeCard(
                                  episode,
                                  loading: loading,
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 30),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "View all ${podcast.totalEpisodes} episodes ",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                        child: Text(
                          "About",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          podcast.description,
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.15,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      infoRow("Country", podcast.country),
                      infoRow("Publisher", podcast.publisher),
                      infoRow("Explicit content", podcast.explicitContent ? "YES" : "NO"),
                      infoRow("First episode", podcast.firstEpisodeDate.formattedString),
                      infoRow("Last episode", podcast.lastEpisodeDate.formattedString),
                      infoRow("Contact", podcast.email, showDivider: false),

                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text(
                          "Related",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        height: 270,
                        width: size.width,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _loading,
                          builder: (context, loading, _) => ListView.builder(
                              itemCount: 6,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (_, index) {
                                if (index == 5) return SizedBox(width: 30);
                                final relatedPodcast = loading ? Podcast.dummy() : podcast.related.elementAt(index);
                                return VerticalPodcastCard(
                                  relatedPodcast,
                                  loading: loading,
                                );
                              }),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget infoRow(String attribute, String value, {bool showDivider = true}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    attribute,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
            SizedBox(height: 3),
            if (showDivider)
              Container(
                height: 1,
                color: Colors.black.withOpacity(0.2),
              ),
          ],
        ),
      );
}
