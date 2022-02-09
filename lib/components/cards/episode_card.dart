import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';
import '../../util/extensions.dart';

class EpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;
  final bool loading;

  EpisodeCard(this.episode, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 135,
        padding: const EdgeInsets.all(10),
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
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Stack(children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: episode.thumbnailUrl,
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
                                  stops: [0.1, 0.7, 1.0],
                                  tileMode: TileMode.decal),
                            ),
                          ),
                        ),
                        Center(
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 15,
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ]),
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
                        Text(
                          "${episode.releaseDate.formattedString}",
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${episode.title}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "${episode.description}",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          episode.durationText,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            height: 1.2,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
      ),
      Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Colors.black.withOpacity(0.2),
      )
    ]);
  }
}
