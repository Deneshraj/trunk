import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';

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
      drawer: NavDrawer(),
      body: InputFilesButton(
        text: "Import Db",
        onPressed: () async {
          FilePickerResult res = await FilePicker.platform.pickFiles();
          if(res != null && res.isSinglePick) {
            showSnackbar(context, "Importing DB");
          } else {
            showSnackbar(context, "Please choose a DB file");
          }
        },
      ),
    );
  }
}
