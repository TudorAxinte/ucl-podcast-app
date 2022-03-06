import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String _hint;
  final TextEditingController _controller;
  final IconData icon;
  final bool isPassword;
  final Function(String)? onChanged;

  CustomTextField(this._controller, this._hint, {this.onChanged, this.icon = Icons.text_fields_sharp, this.isPassword
  = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 55,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            SizedBox(width: 5),
            Expanded(
              child: TextFormField(
                controller: _controller,
                cursorColor: Colors.black,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: onChanged,
                obscureText: isPassword,
                decoration: InputDecoration(
                  hintText: _hint,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ));
  }
}
