import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/cards/curated_podcast_card.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/providers/ai_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/providers/users_provider.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';

class LibraryPage extends StatelessWidget {
  final Random _rand = Random();
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<bool> _fetchingRecommendations = ValueNotifier(false);
  late final UsersProvider usersProvider;
  late final AiProvider aiProvider;

  Future<void> fetchMorePlaylists(NetworkDataProvider data, int page) async {
    _loading.value = true;
    await data.fetchCuratedPlaylists(page: page);
    _loading.value = false;
  }

  Future<void> fetchRecommendations() async {
    _fetchingRecommendations.value = true;
    if (!usersProvider.loaded) await usersProvider.init();
    if (!usersProvider.loadedFriends) await usersProvider.fetchFriends();
    await aiProvider.generateWatsonNluRecommendations(
        await aiProvider.generateWatsonNluInput([usersProvider.currentUser!, ...usersProvider.currentUserFriends])
    );
    _fetchingRecommendations.value = false;
  }

  @override
  Widget build(BuildContext context) {
    usersProvider = Provider.of<UsersProvider>(context, listen: false);
    aiProvider = Provider.of<AiProvider>(context, listen: false);
    fetchRecommendations();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.lightBlueAccent.withOpacity(0.95),
          toolbarHeight: 50,
          centerTitle: true,
          title: const TabBar(
            labelStyle: TextStyle(fontSize: 18),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Featured"),
              Tab(text: "Recommended"),
            ],
          ),
        ),
        body: Transform(
          transform: Matrix4.translationValues(0, 15, 0),
          child: Container(
            color: Theme
                .of(context)
                .primaryColor,
            child: TabBarView(
              children: [
                featuredPlaylists(context),
                recommendedPlaylists(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget recommendedPlaylists(context) =>
      ValueListenableBuilder<bool>(
        valueListenable: _fetchingRecommendations,
        builder: (_, fetching, __) =>
            Consumer<AiProvider>(
              builder: (_, aiProvider, __) {
                final List<CuratedPlaylist> playlists = aiProvider.playlists;
                final int length = playlists.length;
                return fetching == false
                    ? ListView.builder(
                    itemCount: length,
                    itemBuilder: (context, index) {
                      final CuratedPlaylist playlist = playlists[index];
                      return _section(context, playlist, isDark: index % 2 == 0);
                    })
                    : loadingPlaylistsPlaceholder(context);
              },
            ),
      );

  Widget featuredPlaylists(context) =>
      Consumer<NetworkDataProvider>(
        builder: (_, data, __) {
          final List<CuratedPlaylist> playlists = data.playlists;
          final int length = playlists.length;
          return data.finishedLoading
              ? ListView.builder(
              itemCount: length + 1,
              itemBuilder: (context, index) {
                if (index == length) return _loadMoreSection(data, length, context);
                final CuratedPlaylist playlist = playlists[index];
                return _section(context, playlist, isDark: index % 2 == 0);
              })
              : loadingPlaylistsPlaceholder(context);
        },
      );

  Widget _section(context, CuratedPlaylist playlist, {isDark = false}) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Theme
            .of(context)
            .backgroundColor,
      ),
      child: Column(
        children: [
          _header(playlist.title, isDark: isDark),
          Container(
            child: CarouselSlider(
              items: playlist.podcasts
                  .map(
                    (podcast) =>
                    InkWell(
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

  Widget _loadMoreSection(data, length, context) =>
      Container(
        height: 100,
        width: 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 40, top: 20),
        child: ValueListenableBuilder<bool>(
          valueListenable: _loading,
          builder: (_, loading, __) =>
          loading
              ? FittedBox(
            child: SizedProgressCircular(
              color: Colors.white,
            ),
          )
              : MaterialButton(
            onPressed: () => fetchMorePlaylists(data, length ~/ 10 + 1),
            color: Colors.white,
            minWidth: 200,
            child: Text(
              "Load more",
              style: TextStyle(
                color: Theme
                    .of(context)
                    .primaryColor,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );

  Widget loadingPlaylistsPlaceholder(context) =>
      SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: MediaQuery
              .of(context)
              .viewPadding
              .top > 20 ? 60 : 30),
          _loadingSection(context, true),
          _loadingSection(context, false),
          _loadingSection(context, true),
        ]),
      );

  Widget _loadingSection(context, isDark) {
    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(vertical: 50),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? Theme
            .of(context)
            .primaryColor : Theme
            .of(context!)
            .backgroundColor,
      ),
      child: Column(
        children: [
          Container(
            child: CarouselSlider(
              items: Iterable.generate(
                3,
                    (e) =>
                    CuratedPodcastCard(
                      Podcast.dummy(),
                      isDark: isDark,
                      loading: true,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title, {isDark = false}) =>
      Padding(
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
