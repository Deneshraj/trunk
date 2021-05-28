import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/db/db_init.dart';
import 'package:trunk/screens/components/input_files_button.dart';
import 'package:trunk/screens/components/input_text_field.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/db_import_export/import_db.dart';
import 'package:trunk/screens/notebook/notebook.dart';
import 'package:trunk/utils/exit_alert.dart';
import 'package:trunk/utils/generate_random_string.dart';

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
    print("$s");
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
  bool _isFirstTime = false;

  Future<bool> isFirstTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

     var isFirstTime = pref.getBool('first_time');
     if (isFirstTime != null && !isFirstTime) {
       pref.setBool('first_time', false);
       return false;
     } else {
       pref.setBool('first_time', false);
       return true;
     }
  }

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
    isFirstTime().then((isFirstTime) {
      setState(() {
        _isFirstTime = isFirstTime;
      });
     });
    }
   );
  }

  Future<void> _handleSubmit(
    DatabaseHelperInit databaseHelperInit,
    String password,
  ) async {
    if (password.isNotEmpty) {
      DatabaseHelper databaseHelper =
          await createDatabaseHelperInstance(password);
      if (databaseHelperInit != null) {
        if (databaseHelper != null) {
          databaseHelperInit.setDatabaseHelper(databaseHelper);
          showSnackbar(context, "Welcome to Trunk");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('first_time', true);

          Navigator.pushReplacementNamed(
            context,
            Notebook.routeName,
          );
        } else {
          // TODO: To close app automatically on 3 attempts
          // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
          showSnackbar(context, "Invalid Password");
        }
      } else {
        showSnackbar(context, "Something went wrong!");
        // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      }
    } else {
      showSnackbar(context, "Please Enter Master password");
      // SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    }
  }

  bool _validate(String password) {
    bool isValid = true;

    if (password.length < 10) {
      showSnackbar(
          context, "Please Enter the password of atleast 10 characters");
      isValid = false;
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final databaseHelperInit = Provider.of<DatabaseHelperInit>(context);
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => exitAlert(context),
      child: Scaffold(
        appBar: AppBar(title: Text("Trunk")),
        body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              InputTextField(
                textInputAction: TextInputAction.go,
                onSubmitted: (value) async {
                  await _handleSubmit(databaseHelperInit, value);
                },
                obscureText: true,
                hintText: "Enter the Master password",
                controller: _passwordController,
              ),
              InputFilesButton(
                text: "Decrypt Notebook",
                onPressed: () async {
                  String password = _passwordController.text.trim();
                  if (_validate(password)) {
                    await _handleSubmit(databaseHelperInit, password);
                  }
                },
              ),
              (!_isFirstTime)
                  ? Container(
                      width: size.width * 0.6,
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text("Generate a Random Password"),
                        onPressed: () {
                          String randomPassword =
                              generateRandomString(18, 1, "()~`");
                          setState(() {
                            _passwordController.text = randomPassword;
                          });
                        },
                      ),
                    )
                  : Text(""),
              Text(
                "OR",
                textAlign: TextAlign.center,
              ),
              InputFilesButton(
                text: "Import DB",
                onPressed: () {
                  Navigator.pushNamed(context, ImportDb.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
