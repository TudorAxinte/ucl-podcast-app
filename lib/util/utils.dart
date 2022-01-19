import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

class SizedProgressCircular extends StatelessWidget {
  final double size;
  final Color? color;

  const SizedProgressCircular({Key? key, this.size = 50, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

Widget optionCard(context, String title, size, IconData icon, function, {String? subtitle}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: function,
      child: Container(
        width: size.width * 0.8,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 0.5,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 0.5,
                    blurRadius: 2.0,
                    offset: Offset(1.0, 1.0),
                  )
                ],
              ),
              child: Icon(
                icon,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    fontSize: size.height * 0.018,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: size.height * 0.014,
                    ),
                  ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    ),
  );
}


Function showCustomBottomSheet(BuildContext context, Widget body, {minHeight, maxHeight}) =>
    () => showCupertinoModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.black12,
          builder: (context) =>
              ConstrainedBox(constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight), child: body),
        );

Future<T?> showDialogBox<T>(BuildContext context, Widget body, height, width) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: body,
      ),
    );


