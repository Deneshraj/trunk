import 'package:flutter/material.dart';

class DisplayNoteRow extends StatelessWidget {
  const DisplayNoteRow({
    Key key,
    this.title,
    this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
            softWrap: true,
          ),
          Text(
            (value.length > 20) ? value.substring(0, 20) + "...": value,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
