import 'package:flutter/material.dart';
import 'package:trunk/screens/decrypt_note/decrypt_note.dart';
import 'package:trunk/screens/share_notes/share_note_with_pass.dart';
import 'package:trunk/screens/share_notes/share_note_with_steg.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> shareNoteList = [
      {
        'title': "Share securely using steganography",
        'onTap': () {
          Navigator.popAndPushNamed(context, ShareNoteWithSteg.routeName);
        },
      },
      {
        'title': "Share securely using password",
        'onTap': () {
          Navigator.popAndPushNamed(context, ShareNoteWithPassword.routeName);
        },
      },
    ];

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: Text(
            "Trunk",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )),
          ListTile(
            title: Text("Import/Export DB"),
            onTap: () {
              print("Import/Export DB");
            },
          ),
          ListTile(
            title: Text("Share key"),
            onTap: () {
              Navigator.popAndPushNamed(context, '/sharekey');
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
              Navigator.popAndPushNamed(context, DecryptNote.routeName);
            },
          ),
          ListTile(
            title: Text("Friends List"),
            onTap: () {
              Navigator.popAndPushNamed(context, '/friendslist');
            },
          ),
          ListTile(
            title: Text("Exit"),
            onTap: () {
              print("exit");
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
