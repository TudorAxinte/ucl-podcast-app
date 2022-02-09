import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/cards/curated_podcast_card.dart';
import 'package:podcasts_app/models/podcasts/currated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatelessWidget {
  final Random _rand = Random();

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    return Container(
      color: Theme.of(context).primaryColor,
      child: Consumer<NetworkDataProvider>(builder: (_, data, __) {
        final List<CuratedPlaylist> playlists = data.playlists;
        return !data.finishedLoading
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: data.playlists.length,
                itemBuilder: (context, index) {
                  final CuratedPlaylist playlist = playlists[index];
                  return _section(context, playlist, isDark: index % 2 == 0);
                })
            : SingleChildScrollView(
                child: Column(children: [
                  SizedBox(height: hasNotch ? 40 : 20),
                  _loadingSection(context, true),
                  _loadingSection(context, false),
                  _loadingSection(context, true),
                ]),
              );
      }),
    );
  }

  Widget _section(context, CuratedPlaylist playlist, {isDark = false}) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Theme.of(context).backgroundColor,
      ),
      child: Column(
        children: [
          _header(playlist.title, isDark: isDark),
          Container(
            child: CarouselSlider(
              items: playlist.podcasts
                  .map(
                    (podcast) => InkWell(
                      child: CuratedPodcastCard(
                        podcast,
                        isDark: isDark,
                      ),
                      onTap: () {
                        showCupertinoModalBottomSheet(
                          barrierColor: Colors.black,
                          topRadius: Radius.circular(20),
                          context: context,
                          builder: (_) => PodcastViewerPage(podcast),
                        );
                      },
                    ),
                  )
                  .toList(),
              options: CarouselOptions(
                aspectRatio: 2.2,
                viewportFraction: 0.4,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(milliseconds: 1200 + _rand.nextInt(100) * 50),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingSection(context, isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context!).primaryColor : Theme.of(context!).backgroundColor,
      ),
      child: Column(
        children: [
          _header("Loading...", isDark: isDark),
          Container(
            child: CarouselSlider(
                items: Iterable.generate(
                  3,
                  (e) => InkWell(
                    child: CuratedPodcastCard(
                      Podcast.dummy(),
                      isDark: isDark,
                      loading: true,
                    ),
                    onTap: () {
                      showCupertinoModalBottomSheet(
                        barrierColor: Colors.black,
                        topRadius: Radius.circular(20),
                        context: context,
                        builder: (_) => PodcastViewerPage(
                          Podcast.dummy(),
                        ),
                      );
                    },
                  ),
                ).toList(),
                options: CarouselOptions(
                  aspectRatio: 2.2,
                  viewportFraction: 0.4,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(milliseconds: 1200 + _rand.nextInt(100) * 50),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                )),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, {isDark = false}) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      );
}
