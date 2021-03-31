import 'package:flutter/material.dart';

class InputFilesButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const InputFilesButton({Key key, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 0)),
          alignment: Alignment.center,
          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
