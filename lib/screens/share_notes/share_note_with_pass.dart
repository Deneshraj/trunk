import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:trunk/model/encrypted_file_params.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/utils/rsa_encrypt.dart';
import 'package:trunk/utils/store_file.dart';

import '../../db/db.dart';

class ShareNoteWithPassword extends StatefulWidget {
  static const routeName = "ShareNoteWithPass";
  @override
  _ShareNoteWithPasswordState createState() => _ShareNoteWithPasswordState();
}

class _ShareNoteWithPasswordState extends State<ShareNoteWithPassword> {
  Note _note;
  Map<String, dynamic> _key;

  Future<Note> _getNoteModal(DatabaseHelper databaseHelper) {
    return getNotebookModal(context, databaseHelper);
  }

  Future<Map<String, dynamic>> _getKeyToEncryptModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    return getKeyToEncryptModal(context, databaseHelper);
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Sharing note with Password"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(width: double.infinity),
            InputFilesButton(
              text: "Select note",
              onPressed: () async {
                Note note = await _getNoteModal(databaseHelper);
                if (note != null) {
                  setState(() {
                    _note = note;
                  });
                } else {
                  showSnackbar(context, "Please Select a Note");
                }
              },
            ),
            (_note != null) ? Text("${_note.title}") : Container(),
            InputFilesButton(
              text: "Select Friend",
              onPressed: () async {
                Map<String, dynamic> friend =
                    await _getKeyToEncryptModal(context, databaseHelper);

                if (friend != null) {
                  setState(() {
                    _key = friend;
                  });
                } else {
                  showSnackbar(
                      context, "Please Select a Friend's list to send note");
                }
              },
            ),
            (_key != null) ? Text("${_key['name']}") : Container(),
            InputFilesButton(
              text: "Encrypt and Share",
              onPressed: () async {
                try {
                  if(_note != null && _key != null) {
                    String jsonString = jsonEncode(_note.toMap());
                    EncryptedFileParams params = await storeEncryptedTemporaryFile(
                        "${_note.title}.nt", jsonString);

                    String encryptedKey =
                        await rsaEncrypt(_key['public_key'], params.key.bytes);
                    Map<String, String> map = {
                      'title': _key['title'],
                      'encryptedText': encryptedKey,
                    };

                    String encryptedKeyPath =
                        await storeTemporaryFile("key.enc", jsonEncode(map));

                    if (params.path != null) {
                      await Share.shareFiles([
                        params.path,
                        encryptedKeyPath,
                      ]);
                    } else {
                      print("Path is null");
                      showSnackbar(context, "Unable to share");
                    }
                  } else {
                    showSnackbar(context, "Please select Note and Friend");
                  }
                } catch(e, s) {
                  print("$e $s");
                  showSnackbar(context, "Error occured while sharing");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}