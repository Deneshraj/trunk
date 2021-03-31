import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/friends.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';

import '../../constants.dart';
import 'components/modal_form.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> friendsList = [];
  static final _defaultBar = AppBar(
    title: Text("Friends List"),
  );
  AppBar _appBar = _defaultBar;
  int _selected;
  bool _initialized = false;

  void _updateFriends(DatabaseHelper databaseHelper) async {
    var _friendsList = await databaseHelper.getFriendsList();

    setState(() {
      friendsList = _friendsList;
      _initialized = true;
    });
  }

  void addFriend(
    DatabaseHelper databaseHelper,
    Friend friend,
  ) async {
    try {
      int result = await databaseHelper.insertFriend(friend);
      if (result != 0) {
        _updateFriends(databaseHelper);
      } else {
        showSnackbar(context, "Error while adding new friend");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> _addFriendsModalBottomSheet(
    BuildContext context,
    DatabaseHelper databaseHelper,
  ) {
    // TODO:Update Functionality
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return ModalForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      _updateFriends(databaseHelper);
    }

    AppBar _selectBar = AppBar(
      title: Text(""),
      leading: GestureDetector(
        onTap: () {
          changeAppbarToDefault();
        },
        child: Icon(Icons.close),
      ),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (string) {
            optionsAction(databaseHelper, string);
          },
          itemBuilder: (BuildContext context) {
            return options.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList();
          },
        ),
      ],
      backgroundColor: Colors.deepPurple,
    );
    return Scaffold(
      appBar: _appBar,
      body: ListView.builder(
          itemCount: friendsList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(
                  "${friendsList[index].name}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onLongPress: () {
                  setState(() {
                    _selected = index;
                    _appBar = _selectBar;
                  });
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var friend =
              await _addFriendsModalBottomSheet(context, databaseHelper);
          if (friend != null) {
            addFriend(databaseHelper, friend);
          } else {
            showSnackbar(context, "Unable to add Friend");
          }
        },
        label: Text("Add Friend"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
    });
  }

  void optionsAction(DatabaseHelper databaseHelper, String option) {
    if (option == DELETE) {
      Friend friend = friendsList[_selected];
      databaseHelper.deleteFriend(friend);
      _updateFriends(databaseHelper);
      changeAppbarToDefault();
    } else if (option == SHARE_WITH_FRIEND) {
      print("Sharing With Friend");
    }
  }
}
