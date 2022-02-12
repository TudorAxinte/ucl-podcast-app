import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GenreCard extends StatelessWidget {
  final String name;
  final Color color;
  final bool loading;

  GenreCard(this.name, this.color, {this.loading = false});

  @override
  Widget build(BuildContext context) {
    return loading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Theme.of(context).primaryColor,
            direction: ShimmerDirection.ltr,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: color,
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: color,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: Text(
              name.replaceAll(" ", "\n"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          );
  }
}
