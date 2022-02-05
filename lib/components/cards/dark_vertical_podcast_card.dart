import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';

class DarkVerticalPodcastCard extends StatelessWidget {
  final Podcast podcast;
  final bool loading;

  DarkVerticalPodcastCard(this.podcast, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return  loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Theme.of(context).primaryColor,
              direction: ShimmerDirection.ltr,
              child: Column(
                children: [
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 5,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 5,
                    color: Colors.grey,
                  ),

                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "${podcast.title}",
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "${podcast.description}",
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.1,
                      fontSize: 11,
                    ),
                  ),
                ),
                SizedBox(
                  height: 3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: RichText(
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: "by ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: podcast.author,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ]),
                  ),
                )
              ],
    );
  }



}
