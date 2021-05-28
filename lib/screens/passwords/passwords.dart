import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/screens/passwords/components/add_password.dart';
import 'package:trunk/screens/passwords/components/alerttextfield.dart';
import 'package:trunk/utils/generate_random_string.dart';

import 'components/fieldsdisplay.dart';

class Passwords extends StatefulWidget {
  static const routeName = "Passwords";
  @override
  _PasswordsState createState() => _PasswordsState();
}

class _PasswordsState extends State<Passwords> {
  List<String> _options = [
    DELETE,
    SHARE_WITH_FRIEND,
  ];

  // TODO: Categories of passwords like banking, social media etc.,
  TextEditingController _urlController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  static final AppBar _defaultBar = AppBar(
    title: Text("passwords"),
  );
  AppBar _appBar = _defaultBar;
  int _selected;
  List<Password> passwords = [];
  bool _initialized = false;

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
    });
  }

  void optionsAction(DatabaseHelper databaseHelper, String option) {
    if (option == DELETE) {
      databaseHelper.deletePassword(passwords[_selected]);
      setState(() {
        passwords.removeAt(_selected);
        _appBar = _defaultBar;
      });
    } else {
      print("Invalid Option");
    }
  }

  void updatePasswords(DatabaseHelper databaseHelper) async {
    Future<List<Password>> passwordsListFuture =
        databaseHelper.getPasswordsList();
    passwordsListFuture.then((passwordsList) {
      setState(() {
        passwords = passwordsList;
        _initialized = true;
      });
    }).catchError((error) => print(error));
  }

  void _showPasswordBottomModalSheet(context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        Size size = MediaQuery.of(context).size;
        return Container(
          height: size.height * 0.8,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(30),
                  child: Text(
                    "Password",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
                FieldsDisplay(
                  name: "URL",
                  value: passwords[index].title,
                ),
                FieldsDisplay(
                  name: "Username",
                  value: passwords[index].username,
                ),
                FieldsDisplay(
                  name: "Password",
                  value: passwords[index].password,
                  isPass: true,
                ),
              ],
            ),
          ),
        );
      },
      elevation: 10.0,
    ).then((value) {
      if (value != null) {
        print(value);
        setState(() {
          passwords.add(value);
        });
      }
    }).catchError((err) => print(err));
  }

  @override
  Widget build(BuildContext context) {
    final databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      updatePasswords(databaseHelper);
    }

    // TODO:add _selectBar to constants
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
            return _options.map((option) {
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
        itemCount: passwords.length,
        itemBuilder: (context, index) => Card(
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: ListTile(
            title: Text(passwords[index].title,
                style: TextStyle(fontWeight: FontWeight.bold)),
            onLongPress: () {
              setState(() {
                _appBar = _selectBar;
                _selected = index;
              });
            },
            onTap: () async {
              _showPasswordBottomModalSheet(context, index);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var res = await Navigator.pushNamed(context, AddPassword.routeName);
          if (res != null && res == true) {
            updatePasswords(databaseHelper);
          }
        },
        label: Text("Password"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
