import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/audio/player.dart';
import 'package:podcasts_app/components/cards/episode_card.dart';
import 'package:podcasts_app/components/search_box.dart';
import 'package:podcasts_app/models/podcast.dart';

class EpisodesViewer extends StatelessWidget {
  final _searchQuery = ValueNotifier("");
  final Podcast podcast;

  EpisodesViewer(this.podcast);

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
                      searched.isEmpty
                          ? "${podcast.episodes.length} entries"
                          : "${podcast.episodes.where((element) => element.title.toLowerCase().contains(
                                searched.toLowerCase(),
                              )).length} results",
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
            ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (_, searched, __) {
                  final episodes = List.from(podcast.episodes);
                  if (searched.isNotEmpty) {
                    episodes.removeWhere(
                      (element) => !element.title.toLowerCase().contains(
                            searched.toLowerCase(),
                          ),
                    );
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: episodes.length,
                      itemBuilder: (_, index) {
                        final episode = episodes[index];

                        return MaterialButton(
                          onPressed: () {
                            showCupertinoModalBottomSheet(
                              barrierColor: Colors.black,
                              topRadius: Radius.circular(20),
                              context: context,
                              builder: (_) => PodcastPlayer(
                                episode,
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
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
