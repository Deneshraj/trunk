import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/db.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/passwords/components/alerttextfield.dart';

import 'components/fieldsdisplay.dart';

class Passwords extends StatefulWidget {
  @override
  _PasswordsState createState() => _PasswordsState();
}

class _PasswordsState extends State<Passwords> {
  // TODO: Categories of passwords like banking, social media etc.,
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

  Future<Password> _addPassword(BuildContext context) {
    TextEditingController _urlController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "New Password",
              textAlign: TextAlign.center,
            ),
            content: ListView(
              children: <Widget>[
                AlertTextField(
                  controller: _urlController,
                  hintText: "URL",
                ),
                AlertTextField(
                  controller: _emailController,
                  hintText: "Email",
                ),
                AlertTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
              ],
            ),
            actions: <Widget>[
              AlertButton(
                text: "Add",
                onPressed: () {
                  String url = _urlController.text.toString();
                  String email = _emailController.text.toString();
                  String password = _passwordController.text.toString();
                  String msg = "";

                  if (url.isEmpty) {
                    if (msg.isEmpty)
                      msg += "Please Enter valid URL";
                    else
                      msg += " URL ";
                  }

                  if (email.isEmpty) {
                    if (msg.isEmpty)
                      msg += "Please Enter valid Email";
                    else
                      msg += " Email ";
                  }

                  if (password.isEmpty) {
                    if (msg.isEmpty)
                      msg += "Please Enter valid Password";
                    else
                      msg += " Password ";
                  }

                  if (msg.isEmpty) {
                    Password returnPass = new Password(
                      title: url,
                      username: email,
                      password: password,
                    );
                    Navigator.of(context).pop(returnPass);
                  } else {
                    showSnackbar(context, msg);
                    Navigator.of(context).pop();
                  }
                },
              ),
              AlertButton(
                text: "Cancel",
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: Colors.grey,
              ),
            ],
          );
        });
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

  void addPassword(DatabaseHelper databaseHelper, Password password) async {
    int result = await databaseHelper.insertPassword(password);

    if (result != 0) {
      showSnackbar(context, "Password saved!");
      updatePasswords(databaseHelper);
    } else {
      showSnackbar(context, "Error while saving");
    }
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
          _addPassword(context).then((result) {
            if (result != null) {
              addPassword(databaseHelper, result);
            }
          }).catchError((err) => print(err));
        },
        label: Text("Password"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}