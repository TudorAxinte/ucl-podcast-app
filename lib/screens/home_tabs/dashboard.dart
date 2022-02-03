import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/animations/fade_animation.dart';
import 'package:podcasts_app/components/cards/category_card.dart';
import 'package:podcasts_app/components/cards/podcast_card.dart';
import 'package:podcasts_app/components/search_box.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import 'package:podcasts_app/util/loading.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  final ValueNotifier<bool> _searching = ValueNotifier(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier("");

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
                        child: SearchBox(
                          onChanged: (value) => _searchQuery.value = value,
                        ),
                      ),
                      InkWell(
                        onTap: () => _searching.value = false,
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
      builder: (_, data, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (_, searched, __) {
                  final List<Podcast> podcasts = List.from(data.podcasts);
                  if (searched.isNotEmpty) _filter(podcasts);
                  return podcasts.isEmpty
                      ? Column(
                          children: [
                            Text(
                              "There are no podcasts \n matching your criteria.",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          itemCount: podcasts.length + 1,
                          itemBuilder: (_, index) {
                            if (index == podcasts.length)
                              return SizedBox(
                                height: 50,
                              );
                            final podcast = podcasts[index];
                            return MaterialButton(
                              onPressed: () {
                                showCupertinoModalBottomSheet(
                                  barrierColor: Colors.black,
                                  topRadius: Radius.circular(20),
                                  context: context,
                                  builder: (_) => PodcastViewerPage(
                                    podcast,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PodcastCard(
                                  podcast,
                                ),
                              ),
                            );
                          });
                }),
          ),
        ],
      ),
    );
  }

  void _filter(List<Podcast> podcasts) {
    final searched = _searchQuery.value.toLowerCase();
    podcasts.removeWhere(
      (element) =>
          !element.title.toLowerCase().contains(searched) ||
          !element.description.toLowerCase().contains(searched) ||
          !element.author.toLowerCase().contains(searched),
    );
  }
}
