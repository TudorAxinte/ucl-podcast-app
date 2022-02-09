
import 'package:flutter/cupertino.dart';

abstract class SearchResult {
  String get id;
  String get title;
  String get author;
  String get thumbnailUrl;
  Widget get page;
}