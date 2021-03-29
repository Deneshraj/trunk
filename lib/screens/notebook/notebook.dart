import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/db.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import '../../constants.dart';
import 'components/nbcard.dart';

class Notebook extends StatefulWidget {
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
    final Future<Database> dbFuture = databaseHelper.initDb();
    dbFuture.then((db) {
      Future<List<Notebooks>> notebookListFuture =
          databaseHelper.getNotebookList();
      notebookListFuture.then((notebookList) {
        setState(() {
          notebooks = [passwordNb] + notebookList;
          _initialized = true;
        });
      });
    });
  }

  void saveNotebook(DatabaseHelper databaseHelper, Notebooks notebook) async {
    if (notebooks.contains(notebook)) {
      showSnackbar(context, "Notebook already created");
    } else {
      int result = await databaseHelper.insertNoteBook(notebook);
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
      body: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
          ),
          Expanded(
            child: GridView.builder(
              itemCount: notebooks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) => (notebooks[index].name == PASSWORD)
                  ? NBCard(
                      text: notebooks[index].name,
                      onTap: () {
                        Navigator.pushNamed(context, '/passwords');
                      },
                    )
                  : NBCard(
                      text: notebooks[index].name,
                      onTap: () {
                        print("${notebooks[index].id}");
                        Navigator.pushNamed(context, '/notes', arguments: notebooks[index].id);
                      },
                      onLongPress: () {
                        setState(() {
                          _appBar = _selectBar;
                          _selected = index;
                        });
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          try {
            getNotebook(context).then((value) {
              if (value != null) {
                saveNotebook(databaseHelper, Notebooks(name: value, createdAt: DateTime.now()));
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

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }