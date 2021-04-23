import 'package:flutter/material.dart';

class NBCard extends StatelessWidget {
  final String text;
  final Function onTap;
  final Function onLongPress;
  final Border border;

  const NBCard({
    Key key,
    this.text,
    this.onTap,
    this.onLongPress,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    bool lightMode = (themeData.brightness == Brightness.light);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 200,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              //TODO: Add the dark mode
              color: (lightMode)
                  ? Colors.grey[300]
                  : themeData.backgroundColor.withAlpha(100),
              blurRadius: 10.0,
            ),
          ],
          color: (lightMode) ? Colors.white : themeData.backgroundColor,
          borderRadius: (border != null) ? null : BorderRadius.circular(10),
          border: (border != null) ? border : Border.all(
            color: (lightMode)
                ? Colors.grey[200]
                : themeData.backgroundColor.withAlpha(100),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
