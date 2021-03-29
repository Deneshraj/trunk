import 'package:flutter/material.dart';

class AlertButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color backgroundColor;

  const AlertButton({
    Key key,
    this.text,
    this.onPressed,
    // TODO:Add the primary color to constants
    this.backgroundColor = Colors.deepPurple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding:
            MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20.0)),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide.none,
          ),
        ),
      ),
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
