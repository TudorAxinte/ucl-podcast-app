import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final bool loading;
  final bool isDark;

  PodcastCard(this.podcast, {this.loading = false, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: isDark ? Colors.transparent : Colors.white,
      ),
      padding: isDark? EdgeInsets.symmetric(horizontal: 20): EdgeInsets.all(10),
      child: loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Theme.of(context).primaryColor,
              direction: ShimmerDirection.ltr,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 5),
                          width: 1000,
                        ),
                        Container(
                          height: 10,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 5),
                          width: 1000,
                        ),
                        Container(
                          height: 10,
                          color: Colors.white,
                          width: 80,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            )
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (isDark)
                Container(
                  width: 1000,
                  height: 1,
                  color: Colors.grey[300]!.withOpacity(0.7),
                ),
              Spacer(),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 10),
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${podcast.title}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        RichText(
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: "by ",
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: podcast.publisher,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    backgroundColor: isDark ? Colors.white : Theme.of(context).primaryColor,
                    child: Icon(
                      Icons.play_arrow,
                      color: isDark ? Theme.of(context).primaryColor : Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
        Spacer(),

      ]),
    );
  }
}
