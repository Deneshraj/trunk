import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/db/db_init.dart';
import 'package:trunk/screens/db_import_export/export_db.dart';
import 'package:trunk/screens/db_import_export/import_db.dart';
import 'package:trunk/screens/decrypt_note/decrypt_note.dart';
import 'package:trunk/screens/friends_list/friends_list.dart';
import 'package:trunk/screens/key/userkey.dart';
import 'package:trunk/screens/notebook/notebook.dart';
import 'package:trunk/screens/notes/components/addnote.dart';
import 'package:trunk/screens/notes/components/editnote.dart';
import 'package:trunk/screens/notes/notes.dart';
import 'package:trunk/screens/passwords/passwords.dart';
import 'package:trunk/screens/share_notes/share_note_with_pass.dart';
import 'package:trunk/screens/share_notes/share_note_with_steg.dart';

import 'screens/password_screen/password_screen.dart';

void main() async {
  /* Todo Section
  TODO:move note from one notebook to another
  TODO:BUG: same notes showing on all notebook
  TODO:Define Architecture and Working
  TODO:Change the color of the selected item
  TODO:Pad the password
  TODO:Are you sure you want to exit section on back button
  TODO:Add Spinner
  */
  runApp(Trunk());
}

DatabaseHelper createDatabaseHelperInstance(String password) {
  try {
    DatabaseHelper databaseHelper = DatabaseHelper();
    databaseHelper.createDbFile();
    databaseHelper.setKey(password);
    // databaseHelper.updateDb();

    return databaseHelper;
  } catch (e, s) {
    print("Exception $e");
    print("Exception $s");
  }

  return null;
}

class Trunk extends StatefulWidget {
  @override
  _TrunkState createState() => _TrunkState();
}

class _TrunkState extends State<Trunk> {
  DatabaseHelperInit databaseHelperInit = DatabaseHelperInit();

  // This widget is the root of your application.
  // TODO:Implement the Steganography
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
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
        initialRoute: PasswordScreen.routeName,
        routes: {
          ImportDb.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelperInit>.value(
                value: databaseHelperInit,
                child: ImportDb(),
              ),
          ExportDb.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelperInit>.value(
                value: databaseHelperInit,
                child: ExportDb(),
              ),
          PasswordScreen.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelperInit>.value(
                value: databaseHelperInit,
                child: PasswordScreen(),
              ),
          Notebook.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: Notebook(),
              ),
          Notes.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: Notes(),
              ),
          AddNote.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: AddNote(),
              ),
          EditNote.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: EditNote(),
              ),
          Passwords.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: Passwords(),
              ),
          UserKey.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: UserKey(),
              ),
          FriendsList.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: FriendsList(),
              ),
          ShareNoteWithPassword.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: ShareNoteWithPassword(steg: false),
              ),
          ShareNoteWithSteg.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: ShareNoteWithPassword(steg: true),
              ),
          DecryptNote.routeName: (context) =>
              ChangeNotifierProvider<DatabaseHelper>.value(
                value: databaseHelperInit.databaseHelper,
                child: DecryptNote(),
              ),
        },
      ),
      providers: [
        ChangeNotifierProvider<DatabaseHelper>.value(
          value: databaseHelperInit.databaseHelper,
        ),
      ],
    );
  }
}
