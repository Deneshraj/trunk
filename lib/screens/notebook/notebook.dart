import 'package:flutter/material.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import '../../constants.dart';
import 'components/nbcard.dart';

class Notebook extends StatefulWidget {
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  // To switch app bar on long press
  static final AppBar _defaultBar = AppBar(
    title: Text(
      "Trunk",
      style: TextStyle(
        fontWeight: FontWeight.w900,
      ),
    ),
  );

  AppBar _appBar = _defaultBar;

  List<String> notebooks = [
    "Password",
  ];

  int _selected;

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
              autofocus: true,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please Enter a valid Notebook name!")),
                  );
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
              TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 30.0)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurple),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                child: Text("Add"),
                onPressed: () {
                  String value = customController.text.toString();
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(value);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Please Enter a valid Notebook name!")),
                    );

                    Navigator.of(context).pop();
                  }
                },
              ),
              TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(horizontal: 20.0)),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void optionsAction(String option) {
    if (option == DELETE) {
      setState(() {
        notebooks.removeAt(_selected);
        _appBar = _defaultBar;
      });
    } else if (option == SHARE_WITH_FRIEND) {
      print("Sharing With Friend");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onSelected: optionsAction,
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
              itemBuilder: (context, index) => NBCard(
                text: notebooks[index],
                onTap: () {
                  Navigator.pushNamed(context, '/notes');
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
                setState(() {
                  this.notebooks.add(value);
                });
              }
            });
          } catch (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error creating new notebook!")),
            );
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