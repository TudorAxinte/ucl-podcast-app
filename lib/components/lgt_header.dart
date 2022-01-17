import 'package:flutter/material.dart';

class LgtHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color1;
  final Color color2;
  final Color textColor;
  final Color? iconColor;

  LgtHeader(this.title, this.icon,
      {this.color1 = Colors.white, this.color2 = Colors.white, this.textColor = Colors.white, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      width: size.width - 40,
      child: Row(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: textColor,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    color1,
                    color2,
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                  stops: [0.4, 1.0],
                  tileMode: TileMode.decal),
              borderRadius: BorderRadius.all(
                Radius.circular(100),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor != null ? iconColor : Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
