import 'package:flutter/material.dart';
import 'components/nbcard.dart';

class Notebook extends StatefulWidget {
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  List<String> notebooks = [
    "password",
  ];

  Future<String> getNotebook(BuildContext context) {
    TextEditingController customController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("New Notebook"),
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
                contentPadding: EdgeInsets.all(10),
                isDense: true,
                hintText: "Enter the name of notebook",
                border: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
              ),
              controller: customController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
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
              MaterialButton(
                elevation: 5.0,
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trunk"),
      ),
      drawer: Drawer(
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
      ),
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
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
      ),
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