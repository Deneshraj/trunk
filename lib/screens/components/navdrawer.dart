import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            title: Text("Home"),
            onTap: () {
              print("home");
            },
          ),
          ListTile(
            title: Text("About"),
            onTap: () {
              print("about");
            },
          ),
          ListTile(
            title: Text("Import/Export DB"),
            onTap: () {
              print("about");
            },
          ),
          ListTile(
            title: Text("Share key"),
            onTap: () {
              print("about");
            },
          ),
          ListTile(
            title: Text("Friends List"),
            onTap: () {
              print("friends list");
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
}