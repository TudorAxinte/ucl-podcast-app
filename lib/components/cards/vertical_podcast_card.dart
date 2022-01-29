import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcast.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';

class VerticalPodcastCard extends StatelessWidget {
  final Podcast podcast;
  final bool loading;

  VerticalPodcastCard(this.podcast, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      child: loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Theme.of(context).primaryColor,
              direction: ShimmerDirection.ltr,
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                    width: 110,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                    width: 110,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 10,
                    width: 110,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 170,
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
                    maxLines: 3,
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
            ),
    );
  }



}
