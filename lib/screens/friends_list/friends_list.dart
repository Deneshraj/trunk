import 'package:flutter/material.dart';
import 'package:trunk/model/friends.dart';
import 'package:trunk/screens/components/navdrawer.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> friendsList = [];
  static final _defaultBar = AppBar(
    title: Text("Friends List"),
  );
  AppBar _appbar = _defaultBar;
  int _selected;
  bool initialized = false;

  void _addFriendsModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Text("Adding Friends"),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar,
      drawer: NavDrawer(),
      body: ListView.builder(
          itemCount: friendsList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text("${friendsList[index].name}"),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _addFriendsModalBottomSheet(context);
        },
        label: Text("Add Friend"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
