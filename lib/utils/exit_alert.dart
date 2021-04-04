import 'package:flutter/material.dart';
import 'package:trunk/screens/components/alertbutton.dart';

Future<bool> exitAlert(BuildContext context) {
  return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Are you sure?'),
          content: Text('Do you want to exit an App'),
          actions: <Widget>[
            AlertButton(
              text: "No",
              backgroundColor: Colors.grey,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            SizedBox(height: 16),
            AlertButton(
              text: "Yes",
              onPressed: () => Navigator.of(context).pop(true),
            ),
            SizedBox(width: 20)
          ],
        ),
      ) ??
      false;
}
