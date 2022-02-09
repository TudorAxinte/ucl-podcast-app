import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/podcasts/podcast_episode.dart';
import 'package:podcasts_app/util/utils.dart';
import '../../util/extensions.dart';

class LightEpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;

  LightEpisodeCard(this.episode);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(bottom: 5),
          width: 1000,
          height: 1,
          color: Colors.grey[300]!.withOpacity(0.7),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.play_arrow,
                color: Colors.blue,
                size: 15,
              ),
            ),

            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${episode.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: "${episode.description}\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "${episode.releaseDate.formattedString}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Stack(children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: episode.thumbnailUrl,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
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
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ]),
    );
  }
}
