import 'package:flutter/material.dart';
import 'package:trunk/constants.dart';

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
        contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        isDense: true,
        hintText: widget.hintText,
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: 4.5, color: Colors.grey[400]),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 5, color: kPrimaryColor),
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
