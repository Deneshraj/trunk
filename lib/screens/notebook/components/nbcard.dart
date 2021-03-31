import 'package:flutter/material.dart';

class NBCard extends StatelessWidget {
  final String text;
  final Function onTap;
  final Function onLongPress;

  const NBCard({
    Key key,
    this.text,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              //TODO: Add the dark mode
              color: Colors.grey[300],
              blurRadius: 30.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[300],
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
