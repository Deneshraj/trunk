import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/elevated_button.dart';
import 'package:trunk/screens/components/input_text_field.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/components/text_button.dart';
import 'package:trunk/utils/exit_alert.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:trunk/utils/text_encrypt.dart';

class DecryptNotebook extends StatefulWidget {
  static const routeName = "DecryptNotebook";
  @override
  _DecryptNotebookState createState() => _DecryptNotebookState();
}

class _DecryptNotebookState extends State<DecryptNotebook> {
  String fileName;
  String notebookName;
  String nbPath;
  List<Note> note;
  TextEditingController _notebookNameController = TextEditingController();

  Future<void> _saveNotebook(
      DatabaseHelper databaseHelper, String nbContents) async {
    Map<String, dynamic> map = jsonDecode(nbContents);

    Keys keys = await databaseHelper.getKeyByTitle(map['key_title']);
    String encryptedAesKey = map['encrypted_key'];
    String key = await rsaDecrypt(
        keys.privateKey, Uint8List.fromList(encryptedAesKey.codeUnits));

    EncryptText cipher =
        EncryptText(enc.Key(Uint8List.fromList(key.codeUnits)));

    // Creating a New Notebook
    Notebooks nb = Notebooks(
      name: _notebookNameController.text,
      createdAt: DateTime.now(),
    );
    await databaseHelper.insertNotebook(nb);
    Notebooks addednb = await databaseHelper.getNotebookByName(nb.name);

    // Getting Notebook filename and writing data into it
    String tempFileName = nb.fileName;
    if(tempFileName != null) {
      String dbFilePath = await databaseHelper.getDbPath(tempFileName);
      File file = File(dbFilePath);

      file.writeAsBytes(cipher.decryptAsBytes(map['encrypted_text']));
    }
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return exitAlert(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Decrypt Notebook"),
        ),
        drawer: NavDrawer(),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child: InputTextField(
                onSubmitted: (String value) {
                  print("$value");
                },
                controller: _notebookNameController,
                hintText: "Enter the name of the Notebook",
              ),
            ),
            CustomTextButton(
              text: "Choose Notebook File",
              onPressed: () async {
                try {
                  FilePickerResult result =
                      await FilePicker.platform.pickFiles();
                  if (result.isSinglePick) {
                    String path = result.files.single.path;
                    List<String> names = result.names;

                    if (path != null) {
                      print("${names[0]}, $path");
                      setState(() {
                        fileName = names[0];
                        nbPath = path;
                      });
                    } else {
                      showSnackbar(context, "Unable to open file!");
                    }
                  } else {
                    showSnackbar(context, "Please select only one file");
                  }
                } catch (e, s) {
                  print("$e $s");
                }
              },
            ),
            CustomElevatedButton(
              text: "Decrypt Notebook",
              onPressed: () async {
                print("$fileName $nbPath");
                try {
                  if (fileName != null || nbPath != null) {
                    if (this.nbPath != null && this.nbPath.endsWith('.nb')) {
                      File notebookFile = File(nbPath);
                      String nbContents = await notebookFile.readAsString();
                      _saveNotebook(databaseHelper, nbContents);
                    } else {
                      showSnackbar(context, "Please Select a Notebook file");
                    }
                  } else {
                    showSnackbar(
                        context, "Please choose a Notebook file");
                    setState(() {
                      fileName = null;
                      nbPath = null;
                    });
                  }
                } catch (e, s) {
                  print("$e $s");
                  showSnackbar(context, "An Error Occured while Decrypting!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
