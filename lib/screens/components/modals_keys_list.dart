import 'package:flutter/material.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/friends.dart';

class ModalKeysList extends StatefulWidget {
  final DatabaseHelper databaseHelper;

  const ModalKeysList({Key key, @required this.databaseHelper})
      : super(key: key);

  @override
  _ModalKeysListState createState() => _ModalKeysListState();
}

class _ModalKeysListState extends State<ModalKeysList> {
  List<Friend> keysList = [];
  bool _initialized = false;

  void getKeys() async {
    var _friendsList = await widget.databaseHelper.getFriendsList();

    setState(() {
      keysList = _friendsList;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!_initialized) {
      getKeys();
    }
    
    return Container(
      child: ListView.builder(
        itemCount: keysList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text("${keysList[index].name}"),
              onTap: () {
                Map<String, dynamic> map = {
                  'name': keysList[index].name,
                  'title': keysList[index].title,
                  'public_key': keysList[index].key,
                };
                Navigator.pop(context, map);
              },
            ),
          );
        },
      ),
    );
  }
}
