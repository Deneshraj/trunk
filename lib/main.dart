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
import 'package:trunk/screens/passwords/components/add_password.dart';
import 'package:trunk/screens/passwords/passwords.dart';
import 'package:trunk/screens/share_notes/share_note_with_pass.dart';
import 'package:trunk/utils/theme_notifier.dart';

import 'screens/password_screen/password_screen.dart';

void main() async {
  /* Todo Section
  TODO:move note from one notebook to another
  TODO:Define Architecture and Working
  TODO:Change the color of the selected item
  TODO:Pad the password
  TODO:Add Spinner
  TODO:Default qr code
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
    ThemeNotifier _notifier = ThemeNotifier();

    return MultiProvider(
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          ThemeMode themeMode = ThemeMode.light;
          if (notifier != null) {
            themeMode = (notifier.light) ? ThemeMode.light : ThemeMode.dark;
          }
          return MaterialApp(
            title: 'Trunk',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: kPrimaryColor,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                brightness: Brightness.light,
                centerTitle: true,
              ),
              brightness: Brightness.light,
              primaryColor: kPrimaryColor,
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: kPrimaryColor,
              ),
              textTheme: TextTheme(
                bodyText2: TextStyle(
                  fontFamily: "mulish",
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              accentColor: Colors.black,
              accentIconTheme: IconThemeData(color: Colors.white),
              dividerColor: Colors.white54,
            ),
            darkTheme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: kPrimaryColor,
                titleTextStyle: TextStyle(
                  color: kPrimaryColor,
                ),
                centerTitle: true,
                foregroundColor: kPrimaryColor,
                elevation: 0,
              ),
              brightness: Brightness.dark,
              primaryColor: kPrimaryColor,
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              textTheme: TextTheme(
                bodyText2: TextStyle(
                  fontFamily: "mulish",
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              accentColor: Colors.white,
              accentIconTheme: IconThemeData(color: Colors.black),
              dividerColor: Colors.black12,
            ),
            themeMode: themeMode,
            // themeMode: ThemeMode.dark,
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
              AddPassword.routeName: (context) =>
                  ChangeNotifierProvider<DatabaseHelper>.value(
                    value: databaseHelperInit.databaseHelper,
                    child: AddPassword(),
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
              ShareNoteWithPassword.stegRouteName: (context) =>
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
          );
        },
      ),
      providers: [
        ChangeNotifierProvider<DatabaseHelper>.value(
          value: databaseHelperInit.databaseHelper,
        ),
        ChangeNotifierProvider<ThemeNotifier>.value(value: _notifier),
      ],
    );
  }
}
