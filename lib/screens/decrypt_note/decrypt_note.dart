import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/text_encrypt.dart';

class DecryptNote extends StatefulWidget {
  static const routeName = "DecryptNote";
  @override
  _DecryptNoteState createState() => _DecryptNoteState();
}

class _DecryptNoteState extends State<DecryptNote> {
  Note note;
  String fileName;
  String keyFileName;
  String notePath;
  String keyPath;

  Future<Notebooks> _getNotebooksModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    try {
      return getNotebookOnlyModal(context, databaseHelper);
    } catch (e, s) {
      print("Unable to select notebook: $s");
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Decrypt Note"),
      ),
      body: Column(
        // TODO:To make this as new widget in new file to avoid redundancy in share_note page
        children: <Widget>[
          SizedBox(width: double.infinity),
          InputFilesButton(
            text: "Choose Note File",
            onPressed: () async {
              try {
                FilePickerResult result = await FilePicker.platform.pickFiles();
                if (result.isSinglePick) {
                  String path = result.files.single.path;
                  List<String> names = result.names;

                  if (path != null) {
                    setState(() {
                      fileName = names[0];
                      notePath = path;
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
          (fileName != null) ? Text("$fileName") : Container(),
          InputFilesButton(
            text: "Choose Key File",
            onPressed: () async {
              try {
                FilePickerResult result = await FilePicker.platform.pickFiles();
                if (result.isSinglePick) {
                  String path = result.files.single.path;
                  List<String> names = result.names;
                  if (path != null) {
                    setState(() {
                      keyFileName = names[0];
                      keyPath = path;
                    });
                  } else {
                    showSnackbar(context, "Unable to decrypt Note");
                  }
                } else {
                  showSnackbar(context, "Please select only one file");
                }
              } catch (e, s) {
                print("$e $s");
              }
            },
          ),
          (keyFileName != null) ? Text("$keyFileName}") : Container(),
          InputFilesButton(
            text: "Decrypt Note",
            onPressed: () async {
              try {
                if (this.keyPath != null && this.notePath != null) {
                  File file = File(keyPath);
                  String contents = await file.readAsString();
                  File noteFile = File(notePath);
                  String noteContents = await noteFile.readAsString();
                  Map<String, dynamic> map = jsonDecode(contents);

                  Keys keys = await databaseHelper.getKeyByTitle(map['title']);
                  String encryptedAesKey = map['encryptedText'];
                  String key = await rsaDecrypt(keys.privateKey,
                      Uint8List.fromList(encryptedAesKey.codeUnits));

                  EncryptText cipher =
                      EncryptText(enc.Key(Uint8List.fromList(key.codeUnits)));
                  String decryptedContents = cipher.aesDecrypt(noteContents);

                  setState(() {
                    note = Note.fromMapObject(jsonDecode(decryptedContents));
                  });
                } else {
                  showSnackbar(context, "Please Select Key and Note files");
                }
              } catch (e, s) {
                print("$e $s");
              }
            },
          ),
          (note != null)
              ? DisplayNote(
                  note: note,
                )
              : Container(),
          (note != null)
              ? InputFilesButton(
                  text: "Add Note to Notebook",
                  onPressed: () async {
                    Notebooks notebook =
                        await _getNotebooksModal(context, databaseHelper);
                    if (notebook != null) {
                      note.id = null;
                      int result =
                          await databaseHelper.insertNote(note, notebook);

                      if (result != 0) {
                        showSnackbar(context, "Note saved Successfully");
                      } else {
                        showSnackbar(
                            context, "Unable to save note to notebook");
                      }
                    } else {
                      showSnackbar(
                          context, "Please select notebook to save note");
                    }
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}

class DisplayNote extends StatelessWidget {
  final Note note;

  const DisplayNote({Key key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DisplayNoteRow(title: "Title", value: note.title),
        DisplayNoteRow(title: "Note", value: note.note),
        DisplayNoteRow(
            title: "Date Created", value: note.dateCreated.toIso8601String()),
      ],
    );
  }
}

class DisplayNoteRow extends StatelessWidget {
  const DisplayNoteRow({
    Key key,
    this.title,
    this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
