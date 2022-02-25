import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/animations/fade_animation.dart';
import 'package:podcasts_app/animations/fly_from_left_animation.dart';
import 'package:podcasts_app/components/audio/podcast_player.dart';
import 'package:podcasts_app/components/cards/genre_card.dart';
import 'package:podcasts_app/components/cards/search_result_card.dart';
import 'package:podcasts_app/components/search_box.dart';
import 'package:podcasts_app/components/value_listenable_builder_2.dart';
import 'package:podcasts_app/components/value_listenable_builder_3.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/models/search_result.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:provider/provider.dart';
import 'package:podcasts_app/util/extensions.dart';

enum SearchFilter { PODCASTS, EPISODES, CURATED_PLAYLISTS, ALL }
enum Parameter { GENRE, LANGUAGE, REGION }

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
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _searching = ValueNotifier(false);
  final ValueNotifier<bool> _fetchingData = ValueNotifier(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier("");
  final ValueNotifier<bool> _showParameters = ValueNotifier(false);
  final ValueNotifier<int?> _selectedGenre = ValueNotifier(null);
  final ValueNotifier<String?> _selectedLanguage = ValueNotifier(null);
  final ValueNotifier<String?> _selectedRegion = ValueNotifier(null);
  final ValueNotifier<SearchFilter> _selectedFilter = ValueNotifier(SearchFilter.PODCASTS);
  final NetworkDataProvider data = NetworkDataProvider();

  Future<void> _fetchSearchResults() async {
    final query = _searchQuery.value;
    EasyDebounce.debounce('search', Duration(milliseconds: 300), () async {
      _fetchingData.value = true;
      if (query.isNotEmpty) await data.fetchSearchResults(query, type: _selectedFilter.value.typeString);
      _fetchingData.value = false;
    });
  }

  Future<void> _searchBestPodcastsByGenre(int id) async {
    _fetchingData.value = true;
    _showParameters.value = true;
    _selectedGenre.value = id;
    _searching.value = true;
    await data.fetchBestPodcasts(genreId: id);
    _fetchingData.value = false;
  }

  Future<void> _searchBestPodcastsByParameters() async {
    _fetchingData.value = true;
    await data.fetchBestPodcasts(
      language: _selectedLanguage.value,
      genreId: _selectedGenre.value,
      region: _selectedRegion.value,
    );
    _fetchingData.value = false;
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
                        child: Stack(children: [
                          SearchBox(
                              autofocus: true,
                              controller: _controller,
                              typeAheadFunction: data.fetchSearchSuggestions,
                              onSuggestionClicked: (value) {
                                _controller.text = value;
                                _searchQuery.value = value;
                                _fetchSearchResults();
                              },
                              onChanged: (value) {
                                _searchQuery.value = value;
                                _fetchSearchResults();
                              }),
                          ValueListenableBuilder<bool>(
                            valueListenable: _showParameters,
                            builder: (_, show, __) => InkWell(
                              onTap: () {
                                if (show) {
                                  _showParameters.value = false;
                                  _selectedGenre.value = null;
                                  _selectedRegion.value = null;
                                  _selectedLanguage.value = null;
                                } else {
                                  _showParameters.value = true;
                                }
                              },
                              child: Container(
                                width: 35,
                                height: 35,
                                margin: EdgeInsets.only(
                                  top: 15,
                                  left: size.width - 125,
                                ),
                                child: Icon(
                                  Icons.filter_alt_outlined,
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                  color: show ? Theme.of(context).primaryColor : Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Transform(
                        transform: Matrix4.translationValues(
                          -15,
                          0,
                          0,
                        ),
                        child: InkWell(
                          onTap: () {
                            _searching.value = false;
                            _searchQuery.value = "";
                            _controller.text = "";
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
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
    final List _genreColors = [
      Colors.purple,
      Colors.orangeAccent,
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.deepPurple,
      Colors.pinkAccent,
      Colors.lightGreen,
      Colors.lightBlue,
      Colors.cyan
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                  width: 30,
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
          SizedBox(height: 20),
          Consumer<NetworkDataProvider>(builder: (_, data, __) {
            final Map genres = data.genres;
            final loading = !data.finishedLoading;
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: loading ? 21 : genres.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                if (loading) {
                  return GenreCard("", Colors.grey, loading: true);
                } else {
                  final id = genres.keys.elementAt(index);
                  final name = genres[id];
                  return InkWell(
                    onTap: () => _searchBestPodcastsByGenre(id),
                    child: GenreCard(
                      name,
                      index < _genreColors.length ? _genreColors[index] : _genreColors[index % _genreColors.length],
                    ),
                  );
                }
              },
            );
          }),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              children: [
                Text(
                  "Still undecided?",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Spacer(),
                InkWell(
                  child: Text(
                    "Play a random episode.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onTap: () {
                    showCupertinoModalBottomSheet(
                      barrierColor: Colors.black,
                      topRadius: Radius.circular(20),
                      context: context,
                      builder: (_) => PodcastPlayer(),
                    );
                  },
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _search(context) {
    return Consumer<NetworkDataProvider>(
      builder: (_, data, __) {
        final List<SearchResult> searchPool = [...data.podcasts, ...data.podcastEpisodes, ...data.playlists];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<bool>(
                valueListenable: _showParameters,
                builder: (_, show, __) {
                  return Visibility(
                    visible: show,
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 10, left: 30, right: 20),
                      child: Row(children: [
                        ValueListenableBuilder(
                          valueListenable: _selectedGenre,
                          builder: (_, selected, ___) => parameterCard(
                            context,
                            selected == null ? Parameter.GENRE.toString().formatAsTitle : data.genres[selected]!,
                            ["Any genre", ...data.genres.values],
                            (int index) {
                              _selectedGenre.value = index == 0 ? null : data.genres.keys.elementAt(index - 1);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ValueListenableBuilder<String?>(
                          valueListenable: _selectedLanguage,
                          builder: (_, selected, ___) => parameterCard(
                            context,
                            selected == null ? Parameter.LANGUAGE.toString().formatAsTitle : selected,
                            ["Any language", ...data.languages],
                            (int index) {
                              _selectedLanguage.value =
                                  index == 0 ? null : _selectedLanguage.value = data.languages.elementAt(index - 1);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectedRegion,
                          builder: (_, selected, ___) => parameterCard(
                            context,
                            selected == null ? Parameter.REGION.toString().formatAsTitle : data.regions[selected]!,
                            ["Any region", ...data.regions.values],
                            (int index) {
                              _selectedRegion.value =
                                  index == 0 ? null : _selectedRegion.value = data.regions.keys.elementAt(index - 1);
                            },
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
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
              child: ValueListenableBuilder3(
                _selectedGenre,
                _selectedLanguage,
                _selectedRegion,
                builder: (_, __, ___, ____, _____) => ValueListenableBuilder2<String, SearchFilter>(
                  _searchQuery,
                  _selectedFilter,
                  builder: (_, searched, selected, __) {
                    final List<SearchResult> results = _searchResults(searchPool).toList();
                    return ValueListenableBuilder<bool>(
                      valueListenable: _fetchingData,
                      builder: (_, fetching, __) => fetching
                          ? Center(
                              child: SizedProgressCircular(),
                            )
                          : results.isEmpty
                              ? Center(
                                  child: Text(
                                    _searchQuery.value.isEmpty
                                        ? "Search any subject and we'll \nfind something worth listening!"
                                        : "There are no search results \n matching your criteria.\n\n",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black),
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
                                          builder: (_) => result.page,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: SearchResultCard(result),
                                      ),
                                    );
                                  }),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget parameterCard(context, String title, Iterable<String> values, onSelect) => Expanded(
        child: InkWell(
          onTap: () {
            showDialogBox(
              context,
              Container(
                width: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: values.length,
                        itemBuilder: (_, index) => ListTile(
                          onTap: () {
                            onSelect(index);
                            if (index != 0) _searchBestPodcastsByParameters();
                            Navigator.of(context).pop();
                          },
                          title: Text(
                            values.elementAt(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      );

  Iterable<SearchResult> _searchResults(List<SearchResult> searchPool) {
    final SearchFilter selectedType = _selectedFilter.value;
    final List<SearchResult> filteredSearchPool = List.from(
      selectedType == SearchFilter.ALL
          ? searchPool
          : searchPool.where(
              (result) => result.runtimeType == selectedType.objectType,
            ),
    );

    if (_selectedGenre.value != null)
      filteredSearchPool.retainWhere((element) {
        if (element is Podcast) return element.genresIds.contains(_selectedGenre.value);
        if (element is PodcastEpisode) return element.podcast.genresIds.contains(_selectedGenre.value);
        if (element is CuratedPlaylist)
          return element.podcasts
              .where(
                (element) => element.genresIds.contains(_selectedGenre.value),
              )
              .isNotEmpty;
        return false;
      });

    if (_selectedRegion.value != null)
      filteredSearchPool.retainWhere((element) {
        final region = data.regions[_selectedRegion.value];
        if (element is Podcast) return element.country == region;
        if (element is PodcastEpisode) return element.podcast.country == region;
        if (element is CuratedPlaylist)
          return element.podcasts
              .where(
                (element) => element.country == region,
              )
              .isNotEmpty;
        return false;
      });

    if (_selectedLanguage.value != null)
      filteredSearchPool.retainWhere((element) {
        if (element is Podcast) return element.language == _selectedLanguage.value;
        if (element is PodcastEpisode) return element.podcast.language == _selectedLanguage.value;
        if (element is CuratedPlaylist)
          return element.podcasts
              .where(
                (element) => element.language == _selectedLanguage.value,
              )
              .isNotEmpty;
        return false;
      });

    if (_searchQuery.value.isEmpty) return filteredSearchPool;
    final searched = _searchQuery.value.toLowerCase();
    return filteredSearchPool.where(
      (result) => result.title.toLowerCase().contains(searched) || result.author.toLowerCase().contains(searched),
    );
  }
}
