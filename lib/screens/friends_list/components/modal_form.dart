import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:trunk/model/friends.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/snackbar.dart';

class ModalForm extends StatefulWidget {
  @override
  _ModalFormState createState() => _ModalFormState();
}

class _ModalFormState extends State<ModalForm> {
  TextEditingController _friendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Text(
              "Adding Friends",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            TextField(
              autofocus: true,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  showSnackbar(context, "Please Enter a valid Friend name!");
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop(value);
                }
              },
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                isDense: true,
                hintText: "Friend Name",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              style: TextStyle(fontSize: 18),
              controller: _friendController,
            ),
            AlertButton(
              text: "Import file",
              onPressed: () async {
                if (_friendController.text.isNotEmpty) {
                  try {
                    FilePickerResult result =
                        await FilePicker.platform.pickFiles();
                    String path = result.files.single.path;
                    if (path.endsWith(".aes")) {
                      File file = File(path);
                      String keyJson = await file.readAsString();

                      Map<String, dynamic> jsonData = jsonDecode(keyJson);
                      Friend friend = Friend(
                        name: _friendController.text,
                        key: Friend.strToPublicKey(jsonData['key']),
                        title: jsonData['title'],
                        createdAt: DateTime.now(),
                      );
                      Navigator.pop(context, friend);
                    } else {
                      showSnackbar(
                        context,
                        "Invalid File ${path.split('/')[-1]}",
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print(e);
                    showSnackbar(
                        context, "An Error occured while creating file");
                    Navigator.pop(context);
                  }
                } else {
                  showSnackbar(context, "Please Enter valid Friend name");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
