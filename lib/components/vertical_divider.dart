import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget Vertical_divider(double height) {
  return Row(
      children: [

        SizedBox(width: 50),

        Container(
          color: Color(0xff383A84),
          height: height,
          width: 10),

        SizedBox(width: 50),

  ]);
}