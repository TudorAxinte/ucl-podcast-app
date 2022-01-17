import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget Horizontal_divider() {
  return Column(
      children: [

        SizedBox(height: 30),

        Container(
            color: Colors.white,
            height: 3,
            width: 120),

        SizedBox(height: 30),

      ]);
}