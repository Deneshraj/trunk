import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/db.dart';
import 'package:trunk/screens/friends_list/friends_list.dart';
import 'package:trunk/screens/key/userkey.dart';
import 'package:trunk/screens/notebook/notebook.dart';
import 'package:trunk/screens/notes/components/addnote.dart';
import 'package:trunk/screens/notes/components/editnote.dart';
import 'package:trunk/screens/notes/notes.dart';
import 'package:trunk/screens/passwords/passwords.dart';
void main() async {
  /* Todo Section
  TODO:move note from one notebook to another
  TODO:BUG: same notes showing on all notebook
  */
  runApp(Trunk());
}

class Trunk extends StatefulWidget {
  @override
  _TrunkState createState() => _TrunkState();
}

DatabaseHelper createDatabaseHelperInstance(String password) {
  DatabaseHelper databaseHelper = DatabaseHelper();
  databaseHelper.setKey(password);

  return databaseHelper;
}

class _TrunkState extends State<Trunk> {
  final DatabaseHelper databaseHelper = createDatabaseHelperInstance("test");
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trunk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kPrimaryColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        accentColor: Colors.black,
        accentIconTheme: IconThemeData(color: Colors.white),
        dividerColor: Colors.white54,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        accentColor: Colors.white,
        accentIconTheme: IconThemeData(color: Colors.black),
        dividerColor: Colors.black12,
      ),
      themeMode: ThemeMode.light,
      // TODO:change named routes to the class's attribute's name
      initialRoute: '/',
      routes: {
        '/': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: Notebook(),
            ),
        '/notes': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: Notes(),
            ),
        '/addnote': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: AddNote(),
            ),
        '/editnote': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: EditNote(),
            ),
        '/passwords': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: Passwords(),
            ),
        '/sharekey': (context) => ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: UserKey(),
            ),
        '/friendslist': (context) =>
            ChangeNotifierProvider<DatabaseHelper>.value(
              value: databaseHelper,
              child: FriendsList(),
            ),
      },
    );
  }
}
