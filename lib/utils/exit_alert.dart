import 'package:flutter/material.dart';
import 'package:trunk/screens/components/alertbutton.dart';

Future<bool> exitAlert(BuildContext context) {
  return showDialog(
          context: context,
          builder: (context) {
            Size size = MediaQuery.of(context).size;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Are you sure?'),
              content: Text('Do you want to exit an App'),
              actions: <Widget>[
                Container(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: size.width * 0.3,
                        child: AlertButton(
                          text: "No",
                          backgroundColor: Colors.grey[700],
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      Container(
                        width: size.width * 0.3,
                        child: AlertButton(
                          text: "Yes",
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            );
          }) ??
      false;
}
