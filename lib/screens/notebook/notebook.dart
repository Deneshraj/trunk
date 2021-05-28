import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/input_text_field.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/notes/notes.dart';
import 'package:trunk/screens/passwords/passwords.dart';
import 'package:trunk/utils/encrypt_notebook.dart';
import 'package:trunk/utils/exit_alert.dart';
import '../../constants.dart';
import 'components/nbcard.dart';

class Notebook extends StatefulWidget {
  static const routeName = "Notebook";
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  List<String> _options = [
    DELETE,
    SHARE_WITH_FRIEND,
    UPDATE_NOTEBOOK,
  ];

  static final AppBar _defaultBar = AppBar(
    title: Text(
      "Trunk",
    ),
  );
  Notebooks passwordNb = Notebooks(name: PASSWORD, createdAt: DateTime.now());
  AppBar _appBar = _defaultBar;
  List<Notebooks> notebooks = [];
  bool _initialized = false;
  int _selected = 1;

  void initState() {
    super.initState();
  }

  void updateNotebooks(DatabaseHelper databaseHelper) async {
    Future<List<Notebooks>> notebookListFuture =
        databaseHelper.getNotebookList();
    notebookListFuture.then((notebookList) {
      setState(() {
        notebooks = notebookList;
        _initialized = true;
      });
    });
  }

  void saveNotebook(DatabaseHelper databaseHelper, Notebooks notebook) async {
    if (notebooks.contains(notebook)) {
      showSnackbar(context, "Notebook already created");
    } else {
      int result = await databaseHelper.insertNotebook(notebook);
      if (result != 0) {
        updateNotebooks(databaseHelper);
      } else {
        showSnackbar(context, "Error creating new notebook!");
      }
    }
  }

  void deleteNotebook(DatabaseHelper databaseHelper, Notebooks notebook) async {
    int result = await databaseHelper.deleteNotebook(notebook);
    if (result != 0) {
      updateNotebooks(databaseHelper);
    } else {
      showSnackbar(context, "Error while deleting notebook");
    }
  }

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
      _selected = -1;
    });
  }

  Future<String> getNotebook(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
          return AlertDialog(
            title: Text(
              "New Notebook",
              textAlign: TextAlign.center,
            ),
            content: InputTextField(
              controller: customController,
              hintText: "Notebook Name",
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  showSnackbar(context, "Please Enter a valid Notebook name!");
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop(value);
                }
              },
            ),
            actions: <Widget>[
              Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: size.width * 0.3,
                      child: AlertButton(
                        text: "Add",
                        onPressed: () {
                          String value = customController.text.toString();
                          if (value.isNotEmpty) {
                            Navigator.of(context).pop(value);
                          } else {
                            showSnackbar(
                                context, "Please Enter a valid Notebook name!");

                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    Container(
                      width: size.width * 0.3,
                      child: AlertButton(
                        text: "Cancel",
                        backgroundColor: Colors.grey,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        });
  }

  Future<Map<String, dynamic>> _getKeyToEncryptModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    return getKeyToEncryptModal(context, databaseHelper);
  }

  void shareNotebookWithFriend(
    Notebooks nb,
    BuildContext context,
    DatabaseHelper helper,
  ) async {
    // Getting the Key to Share
    Map<String, dynamic> friendKey =
        await _getKeyToEncryptModal(context, helper);

    if (friendKey != null) {
      String path = await helper.getDbPath(nb.fileName);
      File file = File(path);

      // Checking if the file exists
      if (file.existsSync()) {
        // Encrypting the Notebook
        String encPath = await encryptNotebook(friendKey, path, nb.name);

        if (encPath != null) {
          await Share.shareFiles([
            encPath,
          ]);

          changeAppbarToDefault();
        } else {
          // Notebook Not Encrypted
          print("Path is null");
          showSnackbar(context, "Unable to share");
        }
      } else {
        showSnackbar(context, "DB Doesn't Exist!");
      }
    } else {
      showSnackbar(context, "Please select a key to Encrypt");
    }
  }

  void optionsAction(
    BuildContext context,
    DatabaseHelper databaseHelper,
    String option,
  ) async {
    Notebooks nb = notebooks[_selected];
    if (option == DELETE) {
      deleteNotebook(databaseHelper, nb);
      changeAppbarToDefault();
    } else if (option == SHARE_WITH_FRIEND) {
      shareNotebookWithFriend(nb, context, databaseHelper);
    } else if (option == UPDATE_NOTEBOOK) {
      String notebookName = await getNotebook(context);
      Notebooks nb = notebooks[_selected];
      nb.name = notebookName;

      int res = await databaseHelper.updateNotebook(nb);
      print(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      updateNotebooks(databaseHelper);
      changeAppbarToDefault();
    }

    // Getting AppBar Title
    AppBar _selectBar = AppBar(
      title: Text("Notebook"),
      leading: GestureDetector(
        onTap: () {
          changeAppbarToDefault();
        },
        child: Icon(Icons.close),
      ),
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (option) {
            optionsAction(context, databaseHelper, option);
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
    );

    return WillPopScope(
      onWillPop: () async {
        return exitAlert(context);
      },
      child: Scaffold(
        appBar: _appBar,
        drawer: NavDrawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: NBCard(
                text: PASSWORD,
                onTap: () {
                  if (_selected < 0) {
                    Navigator.pushNamed(context, Passwords.routeName);
                  }
                },
                border: Border(
                  left: BorderSide(color: Colors.deepPurple, width: 5.0),
                ),
                onLongPress: () {},
              ),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => NBCard(
                  text: notebooks[index].name,
                  selected: (_selected == index),
                  onTap: () {
                    if (_selected >= 0) {
                      setState(() {
                        _selected = index;
                      });
                    } else {
                      Navigator.pushNamed(
                        context,
                        Notes.routeName,
                        arguments: notebooks[index],
                      );
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _appBar = _selectBar;
                      _selected = index;
                    });
                  },
                ),
                childCount: notebooks.length,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            try {
              getNotebook(context).then((value) {
                if (value != null) {
                  saveNotebook(databaseHelper,
                      Notebooks(name: value, createdAt: DateTime.now()));
                }
              });
            } catch (e) {
              print(e);
              showSnackbar(context, "Error creating new notebook!");
            }
          },
          label: Text("New"),
          icon: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
