import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/db_import_export/export_db.dart';
import 'package:trunk/screens/db_import_export/import_db.dart';
import 'package:trunk/screens/decrypt_note/decrypt_note.dart';
import 'package:trunk/screens/friends_list/friends_list.dart';
import 'package:trunk/screens/key/userkey.dart';
import 'package:trunk/screens/notebook/notebook.dart';
import 'package:trunk/screens/share_notes/share_note_with_pass.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:trunk/utils/theme_notifier.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);
    ThemeNotifier notifier = Provider.of<ThemeNotifier>(context);

    List<Map<String, dynamic>> shareNoteList = [
      {
        'title': "Share securely using steganography",
        'onTap': () {
          Navigator.popAndPushNamed(
              context, ShareNoteWithPassword.stegRouteName);
        },
      },
      {
        'title': "Share securely using password",
        'onTap': () {
          Navigator.pushReplacementNamed(
              context, ShareNoteWithPassword.routeName);
        },
      },
    ];

    return Drawer(
      child: ListView(
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            "Trunk",
            style: TextStyle(
              fontSize: 25,
              fontFamily: "mulish",
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          ListTile(
            title: Text("Home"),
            onTap: () {
              Navigator.pushReplacementNamed(context, Notebook.routeName);
            },
          ),
          ListTile(
            title: Text("Import DB"),
            onTap: () {
              Navigator.pushReplacementNamed(context, ImportDb.routeName);
            },
          ),
          ListTile(
            title: Text("Export DB"),
            onTap: () {
              Navigator.pushReplacementNamed(context, ExportDb.routeName);
            },
          ),
          ListTile(
            title: Text("Share key"),
            onTap: () async {
              Keys key = await databaseHelper.getFirstKey();
              if (key == null) {
                showSnackbar(context, "Please generate your key");
                Navigator.pop(context);
              } else {
                Map<String, dynamic> keyMap = {
                  'key': key.publicKeyToString(),
                  'title': key.title,
                };

                String keysJson = jsonEncode(keyMap);
                String filePath =
                    await storeFileLocally("pub.key", "keys", keysJson);
                if (filePath != null) {
                  await Share.shareFiles([filePath], text: "Key");
                  // deleteFile(filePath);
                } else {
                  showSnackbar(context, "An Error occured while sharing");
                }
              }
            },
          ),
          ListTile(
            title: Text("Generate and Share key"),
            onTap: () {
              Navigator.pushReplacementNamed(context, UserKey.routeName);
            },
          ),
          ExpansionTile(
            title: Text("Share Note"),
            children: shareNoteList
                .map((listItem) =>
                    getSubLists(listItem['title'], listItem['onTap']))
                .toList(),
          ),
          ListTile(
            title: Text("Decrypt Note"),
            onTap: () {
              Navigator.pushReplacementNamed(context, DecryptNote.routeName);
            },
          ),
          ListTile(
            title: Text("Friends List"),
            onTap: () {
              Navigator.pushReplacementNamed(context, FriendsList.routeName);
            },
          ),
          ListTile(
            title: Text("Switch Theme"),
            onTap: () {
              notifier.toggleTheme();
            },
          ),
          ListTile(
            title: Text("Exit"),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }

  ListTile getSubLists(String title, Function onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
      onTap: onTap,
    );
  }
}
