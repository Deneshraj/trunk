import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  final Function onSubmitted;
  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final bool autoFocus;

  const InputTextField({
    Key key,
    this.onSubmitted,
    this.controller,
    this.hintText,
    this.textInputAction = TextInputAction.go,
    this.autoFocus = true,
  }) : super(key: key);
  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      // TODO:Extract this widget and create separate widtet
      autofocus: widget.autoFocus,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        isDense: true,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, color: Colors.grey[400]),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: Colors.grey[400]),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      style: TextStyle(
        fontSize: 18,
        fontFamily: "mulish",
        fontWeight: FontWeight.w500,
      ),
      controller: widget.controller,
    );
  }
}
