import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/db/db_init.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/utils/db_zip.dart';
import 'package:trunk/utils/exit_alert.dart';

class ExportDb extends StatefulWidget {
  static const routeName = "ExportDb";
  @override
  _ExportDbState createState() => _ExportDbState();
}

class _ExportDbState extends State<ExportDb> {
  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelperInit>(context).databaseHelper;

    return WillPopScope(
      onWillPop: () async {
        return exitAlert(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Export DB"),
        ),
        drawer: NavDrawer(),
        body: InputFilesButton(
          text: "Export to",
          onPressed: () async {
            Directory exportedDir = await getExternalStorageDirectory();
            if(exportedDir != null && exportedDir.path != null) {
              String path = await getDatabasesPath();
              Zip zipper = Zip(exportedDir.path, Directory(path));
              File zipFile = await zipper.zip("exported_db.zip");
              if(zipFile != null) {
                showSnackbar(context, "DB File stored in ${exportedDir.path}");
              } else {
                showSnackbar(context, "An Error occured while exporting db!");
              }
            } else {
              showSnackbar(context, "Please select a valid Directory");
            }
          },
        ),
      ),
    );
  }
}