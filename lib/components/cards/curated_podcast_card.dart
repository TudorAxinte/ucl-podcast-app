import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcasts/podcast.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';

class CuratedPodcastCard extends StatelessWidget {
  final Podcast podcast;
  final bool isDark;
  final bool loading;

  CuratedPodcastCard(this.podcast, {this.loading = false, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return loading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Theme.of(context).primaryColor,
            direction: ShimmerDirection.ltr,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Theme.of(context).primaryColor,
              direction: ShimmerDirection.ltr,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
              ),
            ))
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
                    color: isDark ? Colors.white : Colors.black,
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
                child: RichText(
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      text: "by ",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: podcast.publisher,
                          style: TextStyle(
                            color: isDark ? Colors.black : Theme.of(context).primaryColor,
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
