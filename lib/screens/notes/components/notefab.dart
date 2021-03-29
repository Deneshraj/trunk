import 'package:flutter/material.dart';

class NoteFab extends StatelessWidget {
  final String tag;
  final Function onPressed;
  final Color color;
  final IconData iconData;

  const NoteFab({Key key, this.tag, this.onPressed, this.color, this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      isExtended: true,
      heroTag: tag,
      onPressed: onPressed,
      // TODO:create a extension capitalize.
      label: Text("${tag[0].toUpperCase()}${tag.substring(1)}"),
      icon: Icon(iconData),
      backgroundColor: color,
    );
  }
}
