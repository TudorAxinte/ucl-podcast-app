import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {

  final String label;
  final List<String> items;
  final Function? onChanged;
  final String? value;
  final double? width;

  CustomDropdown({
    this.items = const ['Tudor'],
    this.onChanged,
    this.label = '',
    this.value,
    this.width
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 40,
      width: width,
      decoration: BoxDecoration(
        color: Color(0xff383A84),
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(5.0)
      ),
      child: Center(child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: items.map((item) {
            return DropdownMenuItem<String>(
            value: item,
            child: Text(item,
                //overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                "  " + item,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
        onChanged: (value) => onChanged,
        decoration: InputDecoration.collapsed(
          hintText: "  " + label,
          hintStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          // prefixIcon: Icon(Icons.question_answer),,
          fillColor: Colors.white
        ),
        isDense: true,
      ),
    ));

  }
}
