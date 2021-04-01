import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import '../../constants.dart';
import 'components/nbcard.dart';

class Notebook extends StatefulWidget {
  static const routeName = "Notebook";
  // TODO:Add Route Name to all screens
  // Eg., static const routeName = '/notebook';
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  // TODO:Add the Update Operation
  // To switch app bar on long press
  static final AppBar _defaultBar = AppBar(
    title: Text(
      "Trunk",
      style: TextStyle(
        fontWeight: FontWeight.w900,
      ),
    ),
  );
  Notebooks passwordNb = Notebooks(name: PASSWORD, createdAt: DateTime.now());
  AppBar _appBar = _defaultBar;
  List<Notebooks> notebooks = [];
  bool _initialized = false;
  int _selected;

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
    });
  }

  Future<String> getNotebook(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "New Notebook",
              textAlign: TextAlign.center,
            ),
            content: TextField(
              // TODO:Extract this widget and create separate widtet
              autofocus: true,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  showSnackbar(context, "Please Enter a valid Notebook name!");
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop(value);
                }
              },
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                isDense: true,
                hintText: "Notebook Name",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              style: TextStyle(fontSize: 18),
              controller: customController,
            ),
            actions: <Widget>[
              AlertButton(
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
              AlertButton(
                text: "Cancel",
                backgroundColor: Colors.grey,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void optionsAction(DatabaseHelper databaseHelper, String option) {
    if (option == DELETE) {
      deleteNotebook(databaseHelper, notebooks[_selected]);
      setState(() {
        _appBar = _defaultBar;
      });
    } else if (option == SHARE_WITH_FRIEND) {
      print("Sharing With Friend");
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      updateNotebooks(databaseHelper);
    }

    AppBar _selectBar = AppBar(
      // TODO:Write a function that returns this appbar
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
    );

    return Scaffold(
      appBar: _appBar,
      drawer: NavDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/passwords');
              },
              onLongPress: () {},
              child: Container(
                height: 200,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      //TODO: Add the dark mode
                      color: Colors.grey[300],
                      blurRadius: 30.0,
                    ),
                  ],
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: Colors.deepPurple, width: 5.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    PASSWORD,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
                onTap: () {
                  Navigator.pushNamed(context, '/notes',
                      arguments: notebooks[index]);
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
    );
  }
}