import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/db/db_init.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';

class ExportDb extends StatefulWidget {
  static const routeName = "ExportDb";
  @override
  _ExportDbState createState() => _ExportDbState();
}

class _ExportDbState extends State<ExportDb> {
  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelperInit>(context).databaseHelper;

    return Scaffold(
      appBar: AppBar(
        title: Text("Export DB"),
      ),
      drawer: NavDrawer(),
      body: InputFilesButton(
        text: "Export to",
        onPressed: () async {
          String dbPath = await FilePicker.platform.getDirectoryPath();
          if(dbPath != null && dbPath.isNotEmpty) {
            File dbFile = File(dbPath + "trunk.enc");
            // List<Notebooks>  nbList = await databaseHelper.getNotebookList();            
            showSnackbar(context, "Exporting DB to the selected Directory");
          } else {
            showSnackbar(context, "Please select a valid Directory");
          }
        },
      ),
    );
  }
}