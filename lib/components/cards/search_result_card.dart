import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/models/search_reslut.dart';
import 'package:podcasts_app/util/utils.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final bool loading;

  SearchResultCard(this.result, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1000,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
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
                          imageUrl: result.thumbnailUrl,
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
                        "${result.title}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      RichText(
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: result.author,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
    );
  }
}
