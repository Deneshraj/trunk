import 'package:flutter/material.dart';

class AlertTextField extends StatelessWidget {
  const AlertTextField({
    Key key,
    @required this.controller,
    @required this.hintText,
    this.textInputType = TextInputType.text,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        textInputAction: TextInputAction.next,
        keyboardType: textInputType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          isDense: true,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        style: TextStyle(fontSize: 18),
        controller: controller,
      ),
    );
  }
}