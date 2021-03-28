import 'package:flutter/material.dart';

class NBCard extends StatelessWidget {
  final String text;
  final Function onTap;
  final Function onLongPress;

  const NBCard({
    Key key,
    this.text,
    this.onTap, this.onLongPress,
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
              color: Colors.grey[400],
              blurRadius: 10.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
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
