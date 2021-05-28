import 'package:flutter/material.dart';
import 'package:trunk/constants.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const CustomTextButton({Key key, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextButton(
        style: ButtonStyle(
          alignment: Alignment.center,
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          ),
          padding: MaterialStateProperty.all(EdgeInsets.all(15)),
        ),
        child: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}