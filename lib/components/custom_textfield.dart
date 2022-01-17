import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget{

  final TextEditingController _controller;
  final String _hint;
  final Function(String)? onChanged;
  CustomTextField(this._controller, this._hint, {this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              offset: Offset(0, 20),
              spreadRadius: -20,
              blurRadius: 30,
            ),
          ],
        ),
        child: TextFormField(
            controller: _controller,
            cursorColor: Colors.black,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: _hint,
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black),
        ),
      );
  }

}