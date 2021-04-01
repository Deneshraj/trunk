import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/db/db_init.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/notebook/notebook.dart';

Future<DatabaseHelper> createDatabaseHelperInstance(String password) async {
  try {
    DatabaseHelper databaseHelper = DatabaseHelper();
    databaseHelper.createDbFile();
    bool res = await databaseHelper.setKey(password);
    if (res) {
      // databaseHelper.updateDb();
      return databaseHelper;
    }

    return null;
  } on DatabaseException catch (e, s) {
    print("\n\n\n Database Exception $e");
  } catch (e, s) {
    print("Exception $e");
    print("Exception $s");
  }

  return null;
}

class PasswordScreen extends StatefulWidget {
  static const routeName = "PasswordScreen";
  const PasswordScreen({Key key}) : super(key: key);
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController _passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final databaseHelperInit = Provider.of<DatabaseHelperInit>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Trunk")),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            TextField(
                // TODO:Extract this widget and create separate widtet
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  isDense: true,
                  hintText: "Enter the Master password",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1.0),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                style: TextStyle(fontSize: 18),
                controller: _passwordController),
            InputFilesButton(
              text: "Decrypt Notebook",
              onPressed: () async {
                String password = _passwordController.text.trim();

                if (password.isNotEmpty) {
                  DatabaseHelper databaseHelper =
                      await createDatabaseHelperInstance(password);
                  if (databaseHelperInit != null) {
                    if (databaseHelper != null) {
                      databaseHelperInit.setDatabaseHelper(databaseHelper);
                      Navigator.pushReplacementNamed(
                          context, Notebook.routeName);
                    } else {
                      // TODO: To close app automatically on 3 attempts
                      Fluttertoast.showToast(
                        msg: "Incorrect Password!",
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                      // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: "Something went wrong!",
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                    // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: "Please Enter a valid Password",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                  // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
