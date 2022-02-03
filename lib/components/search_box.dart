import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function()? onTap;
  final Function(String)? onChanged;
  final String? hint;

  SearchBox({this.onChanged, this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 45,
      width: size.width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search),
          SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onTap: onTap,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint ?? 'Search',
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          )
        ],
      ),
    );
  }
}
