import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/cards/dark_vertical_podcast_card.dart';
import 'package:podcasts_app/components/cards/light_vertical_podcast_card.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/screens/home_tabs/podcast_pages/podcast_viewer.dart';
import '../../util/extensions.dart';

enum Section { RECOMMENDED, TOP_SHOWS, RECENTLY_ADDED, TRENDING, NEWS, DOCUMENTARIES, COMEDY }

extension ex on Section {
  String get title =>
      this.toString().split(".").last.split("_").map((word) => word.capitalize()).reduce((s1, s2) => "$s1 $s2");
}

class LibraryPage extends StatelessWidget {

  final Random _rand = Random();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColor,
        child: Transform(
          transform: Matrix4.translationValues(0, 20, 0),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              child: Column(
                children: Section.values
                    .asMap()
                    .map((index, section) => MapEntry(
                          index,
                          Transform(
                            transform: Matrix4.translationValues(0, -20.0 * index, 0),
                            child: _section(context, index),
                          ),
                        ))
                    .values
                    .toList(),
              ),
            ),
          ),
        ));
  }

  Widget _section(context, index) {
    final isDark = index % 2 == 0;
    final Section section = Section.values[index];

    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: isDark ? Theme.of(context!).primaryColor : Theme.of(context!).backgroundColor,
      ),
      child: Column(
        children: [
          _header(section.title, isDark: isDark),
          Container(
            child: CarouselSlider(
                items: Iterable.generate(
                  5,
                  (e) => InkWell(
                    child: isDark
                        ? LightVerticalPodcastCard(
                            Podcast.dummy(),
                          )
                        : DarkVerticalPodcastCard(
                            Podcast.dummy(),
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
        padding: EdgeInsets.only(left: 30, right: 30, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: "Pacifico",
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            Container(
              height: 1,
              color: isDark ? Colors.white70 : Colors.black54,
              margin: const EdgeInsets.only(bottom: 10, top: 5),
            ),
          ],
        ),
      );
}
