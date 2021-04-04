import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/utils/db_zip.dart';

class ImportDb extends StatefulWidget {
  static const routeName = "ImportDb";
  @override
  _ImportDbState createState() => _ImportDbState();
}

class _ImportDbState extends State<ImportDb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import DB"),
      ),
      body: InputFilesButton(
        text: "Import Db",
        onPressed: () async {
          FilePickerResult result = await FilePicker.platform.pickFiles();
          if(result != null && result.isSinglePick) {
            showSnackbar(context, "Importing DB");
            String path = await getDatabasesPath();
            Zip zipper = Zip(result.files[0].path, Directory(path));
            String res = await zipper.unzip();
            if(res != null) {
              showSnackbar(context, "DB Imported Successfully!");
            } else {
              showSnackbar(context, "Error occured while importing!");
            }
          } else {
            showSnackbar(context, "Please choose a DB file");
          }
        },
      ),
    );
  }
}
