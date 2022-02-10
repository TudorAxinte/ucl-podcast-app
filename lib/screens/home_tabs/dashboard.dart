import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/animations/fade_animation.dart';
import 'package:podcasts_app/animations/fly_from_left_animation.dart';
import 'package:podcasts_app/components/cards/category_card.dart';
import 'package:podcasts_app/components/cards/podcast_card.dart';
import 'package:podcasts_app/components/cards/search_result_card.dart';
import 'package:podcasts_app/components/search_box.dart';
import 'package:podcasts_app/components/value_listanable_builder_2.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/search_result.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:podcasts_app/util/extensions.dart';

enum SearchFilter { ALL, PODCASTS, EPISODES, CURATED_PLAYLISTS }

extension Ex on SearchFilter {
  Type get objectType {
    switch (this) {
      case SearchFilter.PODCASTS:
        return Podcast;
      case SearchFilter.EPISODES:
        return PodcastEpisode;
      case SearchFilter.CURATED_PLAYLISTS:
        return CuratedPlaylist;
      default:
        return SearchResult;
    }
  }

  String? get typeString {
    switch (this) {
      case SearchFilter.PODCASTS:
        return "podcast";
      case SearchFilter.EPISODES:
        return "episode";
      case SearchFilter.CURATED_PLAYLISTS:
        return "curated";
      default:
        return null;
    }
  }
}

class DashboardPage extends StatelessWidget {
  final ValueNotifier<bool> _searching = ValueNotifier(false);
  final ValueNotifier<bool> _fetchingData = ValueNotifier(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier("");
  final ValueNotifier<SearchFilter> _selectedFilter = ValueNotifier(SearchFilter.ALL);

  Future<void> _fetchSearchResults() async {
    final query = _searchQuery.value;
    EasyDebounce.debounce('search', Duration(milliseconds: 300), () async {
      _fetchingData.value = true;
      if (query.isNotEmpty)
        await NetworkDataProvider().fetchSearchResults(
          query,
          type: _selectedFilter.value.typeString,
        );
      _fetchingData.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: size.width,
      padding: EdgeInsets.only(top: hasNotch ? 40 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _searching,
            builder: (_, searching, __) => searching
                ? Row(
                    children: [
                      Expanded(
                        child: SearchBox(onChanged: (value) {
                          _searchQuery.value = value;
                          _fetchSearchResults();
                        }),
                      ),
                      InkWell(
                        onTap: () {
                          _searching.value = false;
                          _searchQuery.value = "";
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(width: 30),
                    ],
                  )
                : SearchBox(
                    onTap: () => _searching.value = true,
                  ),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _searching,
              builder: (_, searching, __) => AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: searching ? _search(context) : _dashboard(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dashboard(context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Consumer<AuthProvider>(
          builder: (_, auth, __) => Row(
            children: [
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeAnimation(
                      2,
                      Text(
                        "Hi ${auth.currentUser!.username}, let's",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    FadeAnimation(
                      6,
                      RichText(
                        text: TextSpan(
                            text: "Podcast ",
                            style: TextStyle(
                              fontFamily: "Pacifico",
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 27,
                            ),
                            children: [
                              TextSpan(
                                text: "Together",
                                style: TextStyle(
                                  fontFamily: "Pacifico",
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 28,
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkResponse(
                onTap: () async {
                  Provider.of<HomeProvider>(context, listen: false).switchToPage(HomeScreen.SETTINGS);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: auth.currentUser!.photoUrl,
                      placeholder: (context, url) => Center(child: StyledProgressBar()),
                      errorWidget: (context, url, error) => Padding(
                        padding: const EdgeInsets.all(25),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
        Container(
          height: 160,
          margin: const EdgeInsets.only(top: 20),
          child: ListView.builder(
            itemCount: PodcastCategory.values.length + 1,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(left: 30),
              child: index == PodcastCategory.values.length ? SizedBox() : CategoryCard(PodcastCategory.values[index]),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
        SizedBox(height: 10),
        Expanded(
          child: Consumer<NetworkDataProvider>(
            builder: (_, data, __) => ListView.builder(
              itemCount: 6,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 25, right: 25),
                child: index == 5
                    ? SizedBox(height: 30)
                    : data.finishedLoading
                        ? ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                padding: MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                barrierColor: Colors.black,
                                topRadius: Radius.circular(20),
                                context: context,
                                builder: (_) => PodcastViewerPage(
                                  Podcast.dummy(),
                                ),
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              child: PodcastCard(Podcast.dummy()),
                            ),
                          )
                        : PodcastCard(Podcast.dummy(), loading: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _search(context) {
    return Consumer<NetworkDataProvider>(
      builder: (_, data, __) {
        final List<SearchResult> searchPool = [...data.podcasts, ...data.podcastEpisodes, ...data.playlists];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<SearchFilter>(
              valueListenable: _selectedFilter,
              builder: (_, selected, __) => Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: SearchFilter.values.length + 1,
                  itemBuilder: (_, index) {
                    if (index == 0)
                      return SizedBox(
                        width: 30,
                      );
                    final SearchFilter filter = SearchFilter.values[index - 1];
                    final bool isSelected = selected == filter;
                    return FlyFromLeftAnimation(
                      index * 50,
                      InkWell(
                        onTap: () {
                          _selectedFilter.value = filter;
                          _fetchSearchResults();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                          ),
                          child: Text(
                            filter.toString().formatAsTitle,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder2<String, SearchFilter>(_searchQuery, _selectedFilter,
                  builder: (_, searched, selected, __) {
                final List<SearchResult> results = _searchResults(searchPool).toList();
                return results.isEmpty
                    ? Center(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _fetchingData,
                          builder: (_, fetching, __) => fetching
                              ? SizedProgressCircular()
                              : Text(
                                  _searchQuery.value.isEmpty
                                      ? "Search any subject and we'll \nfind something worth listening!"
                                      : "There are no search results \n matching your criteria.\n\n",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: results.length + 1,
                        itemBuilder: (_, index) {
                          if (index == results.length) {
                            return SizedBox(height: 50);
                          }
                          final SearchResult result = results[index];
                          return MaterialButton(
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                  barrierColor: Colors.black,
                                  topRadius: Radius.circular(20),
                                  context: context,
                                  builder: (_) => result.page);
                            },
                            child: Padding(padding: const EdgeInsets.only(bottom: 10), child: SearchResultCard(result)),
                          );
                        });
              }),
            ),
          ],
        );
      },
    );
  }

  Iterable<SearchResult> _searchResults(List<SearchResult> searchPool) {
    final SearchFilter selectedType = _selectedFilter.value;
    final Iterable<SearchResult> filteredSearchPool = selectedType == SearchFilter.ALL
        ? searchPool
        : searchPool.where(
            (result) => result.runtimeType == selectedType.objectType,
          );

    if (_searchQuery.value.isEmpty) return filteredSearchPool;
    final searched = _searchQuery.value.toLowerCase();
    return filteredSearchPool.where(
      (result) => result.title.toLowerCase().contains(searched) || result.author.toLowerCase().contains(searched),
    );
  }
}
