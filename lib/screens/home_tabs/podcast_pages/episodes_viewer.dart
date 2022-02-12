import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/audio/podcast_player.dart';
import 'package:podcasts_app/components/cards/episode_card.dart';
import 'package:podcasts_app/components/search_box.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';

class EpisodesViewer extends StatelessWidget {
  final _searchQuery = ValueNotifier("");
  final Podcast podcast;
  final _loading = ValueNotifier(false);

  EpisodesViewer(this.podcast);

  void fetchEpisodes() async {
    _loading.value = true;
    final NetworkDataProvider data = NetworkDataProvider();
    await Future.wait([
      data.fetchNextPodcastEpisodes(podcast),
    ]);
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
        child: Column(
          children: [
            SizedBox(
              height: hasNotch ? 60 : 30,
            ),
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
                  ValueListenableBuilder<String>(
                    valueListenable: _searchQuery,
                    builder: (_, searched, __) => Text(
                      searched.isEmpty ? "${podcast.totalEpisodes} entries" : "${_searchResults().length} results",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SearchBox(onChanged: (value) => _searchQuery.value = value),
            Consumer<NetworkDataProvider>(
              builder: (_, data, __) => ValueListenableBuilder<String>(
                  valueListenable: _searchQuery,
                  builder: (_, searched, __) {
                    final episodes = _searchResults().toList();
                    return AnimatedList(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        initialItemCount: episodes.length,
                        itemBuilder: (_, index, __) {
                          final episode = episodes[index];

                          return MaterialButton(
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                barrierColor: Colors.black,
                                topRadius: Radius.circular(20),
                                context: context,
                                builder: (_) => PodcastPlayer(
                                  podcastEpisode: episode,
                                  playNext: List.from(
                                    podcast.episodes.sublist(index + 1),
                                  ),
                                ),
                              );
                            },
                            child: EpisodeCard(
                              episode,
                            ),
                          );
                        });
                  }),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _loading,
              builder: (_, loading, __) => Padding(
                padding: const EdgeInsets.all(20),
                child: loading
                    ? SizedProgressCircular()
                    : MaterialButton(
                        onPressed: () => fetchEpisodes(),
                        child: Text(
                          "Load more",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Iterable<PodcastEpisode> _searchResults() {
    if (_searchQuery.value.isEmpty) return podcast.episodes;
    final searched = _searchQuery.value.toLowerCase();
    return podcast.episodes.where(
      (element) =>
          element.title.toLowerCase().contains(searched) || element.description.toLowerCase().contains(searched),
    );
  }
}
