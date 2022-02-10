import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchBox extends StatelessWidget {
  final String? hint;
  final bool autofocus;
  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSuggestionClicked;
  final Future<List<String>> Function(String)? typeAheadFunction;
  final TextEditingController? controller;

  SearchBox({
    this.autofocus = false,
    this.onChanged,
    this.hint,
    this.onTap,
    this.typeAheadFunction,
    this.controller,
    this.onSuggestionClicked,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 45,
      width: size.width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search),
          SizedBox(width: 5),
          Expanded(
            child: Container(
              child: typeAheadFunction == null
                ? TextField(
                    controller: controller,
                    autofocus: autofocus,
                    onTap: onTap,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint ?? 'Search',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  )
                : TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      autofocus: autofocus,
                      onTap: onTap,
                      onChanged: onChanged,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint ?? 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                    suggestionsCallback: typeAheadFunction!,
                    hideOnLoading: true,
                    hideOnEmpty: true,
                    hideOnError: true,
                    debounceDuration: Duration(milliseconds: 400),
                    minCharsForSuggestions: 3,
                    noItemsFoundBuilder: (_) => SizedBox(),
                    itemBuilder: (context, suggestion) => Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        suggestion.toString(),
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                    ),
                    onSuggestionSelected: onSuggestionClicked ?? (_) => null,
                  ),
          ),)
        ],
      ),
    );
  }
}
