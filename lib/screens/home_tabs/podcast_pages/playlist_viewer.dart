import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:podcasts_app/components/cards/search_result_card.dart';
import 'package:podcasts_app/models/podcasts/curated_playlist.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/providers/analytics_provider.dart';

class CuratedPlaylistPage extends StatelessWidget {
  final CuratedPlaylist curatedPlaylist;

  CuratedPlaylistPage(this.curatedPlaylist);

  @override
  Widget build(BuildContext context) {
    AnalyticsProvider().setCurrentScreen("Playlist page");
    final podcasts = curatedPlaylist.podcasts;
    final length = podcasts.length;
    return Scaffold(
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
      body: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          itemCount: length + 1,
          itemBuilder: (_, index) {
            if (index == length || index == 0) {
              return index == 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 20),
                      child: Text(
                        curatedPlaylist.title,
                        style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    )
                  : SizedBox(height: 50);
            }
            final Podcast podcast = podcasts[index - 1];
            return MaterialButton(
              onPressed: () {
                showCupertinoModalBottomSheet(
                  barrierColor: Colors.black,
                  topRadius: Radius.circular(20),
                  context: context,
                  builder: (_) => podcast.page,
                ).then(
                  (value) => AnalyticsProvider().setCurrentScreen("Playlist page"),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SearchResultCard(podcast),
              ),
            );
          }),
    );
  }
}
