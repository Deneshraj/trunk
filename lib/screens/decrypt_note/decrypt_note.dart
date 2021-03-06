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
import 'package:trunk/screens/components/elevated_button.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/components/text_button.dart';
import 'package:trunk/steganography/decoder.dart';
import 'package:trunk/steganography/response/decode_response.dart';
import 'package:trunk/utils/exit_alert.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/text_encrypt.dart';

import 'components/display_note.dart';

class DecryptNote extends StatefulWidget {
  static const routeName = "DecryptNote";
  @override
  _DecryptNoteState createState() => _DecryptNoteState();
}

class _DecryptNoteState extends State<DecryptNote> {
  Note note;
  String fileName;
  String notePath;

  String imgFileName;
  String imgNotePath;

  Future<Notebooks> _getNotebooksModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    try {
      return getNotebookOnlyModal(context, databaseHelper);
    } catch (e, s) {
      print("Unable to select notebook: $s");
    }

    return null;
  }

  Future<void> _saveNotes(
      DatabaseHelper databaseHelper, String noteContents) async {
    Map<String, dynamic> map = jsonDecode(noteContents);

    Keys keys = await databaseHelper.getKeyByTitle(map['key_title']);
    String encryptedAesKey = map['encrypted_key'];
    String key = await rsaDecrypt(
        keys.privateKey, Uint8List.fromList(encryptedAesKey.codeUnits));

    EncryptText cipher =
        EncryptText(enc.Key(Uint8List.fromList(key.codeUnits)));
    String decryptedContents = cipher.decryptText(map['encrypted_text']);

    setState(() {
      note = Note.fromMapObject(jsonDecode(decryptedContents));
    });
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    return WillPopScope(
      onWillPop: () => exitAlert(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Decrypt Note"),
        ),
        drawer: NavDrawer(),
        body: Column(
          children: <Widget>[
            SizedBox(width: double.infinity),
            CustomTextButton(
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
            Text("OR"),
            CustomTextButton(
              text: "Choose Image File",
              onPressed: () async {
                try {
                  FilePickerResult result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result.isSinglePick) {
                    String path = result.files.single.path;
                    List<String> names = result.names;

                    if (path != null) {
                      setState(() {
                        imgFileName = names[0];
                        imgNotePath = path;
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
            (imgFileName != null) ? Text("$imgFileName") : Container(),
            CustomElevatedButton(
              text: "Decrypt Note",
              onPressed: () async {
                try {
                  if (fileName != null &&
                      notePath != null &&
                      imgFileName != null &&
                      imgNotePath != null) {
                    showSnackbar(
                        context, "Please choose either image or note file");
                    setState(() {
                      fileName = null;
                      notePath = null;
                      imgFileName = null;
                      imgNotePath = null;
                    });
                  } else {
                    if (this.notePath != null && this.notePath.endsWith('.nt')) {
                      File noteFile = File(notePath);
                      String noteContents = await noteFile.readAsString();
                      _saveNotes(databaseHelper, noteContents);
                    } else if (imgNotePath != null) {
                      File noteFile = File(imgNotePath);
                      

                      if ((await noteFile.readAsBytes()).length > 1000) {
                        DecodeResponse res = decodeMessageFromImage(await noteFile.readAsBytes());
                        String noteContents = res.decodedMsg;
                        _saveNotes(databaseHelper, noteContents);
                      } else {
                        showSnackbar(context, "Image is null");
                      }
                    } else {
                      showSnackbar(context, "Please Select Image or Note file");
                    }
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
                ? CustomTextButton(
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
      ),
    );
  }
}
