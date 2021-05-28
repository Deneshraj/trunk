import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/elevated_button.dart';
import 'package:trunk/screens/components/input_text_field.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/screens/passwords/components/alert_password_field.dart';
import 'package:trunk/screens/passwords/components/alerttextfield.dart';
import 'package:trunk/utils/app_bar.dart';
import 'package:trunk/utils/generate_random_string.dart';

class AddPassword extends StatefulWidget {
  static const routeName = "AddPassword";
  @override
  _AddPasswordState createState() => _AddPasswordState();
}

class _AddPasswordState extends State<AddPassword> {
  TextEditingController _urlController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController customController = TextEditingController();
  bool superSplChars = false;

  void addPassword(DatabaseHelper databaseHelper, Password password) async {
    int result = await databaseHelper.insertPassword(password);

    if (result != 0) {
      showSnackbar(context, "Password saved!");
    } else {
      showSnackbar(context, "Error while saving");
    }
  }

  _getPassGenParams() {
    showDialog(
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
          return AlertDialog(
            title: Text(
              "Generate Password",
              textAlign: TextAlign.center,
            ),
            content: ListView(
              children: <Widget>[
                InputTextField(
                  controller: customController,
                  hintText: "Password Length",
                  textInputAction: TextInputAction.go,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSubmitted: (value) {
                    if (value.isEmpty) {
                      showSnackbar(
                          context, "Please Enter a valid Password Length!");
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop(value);
                    }
                  },
                ),
                CheckboxListTile(
                    value: superSplChars,
                    title: Text("Include Chars like {}[]:;<>,.?/|\\"),
                    onChanged: (value) {
                      print(superSplChars);
                      setState(() {
                        superSplChars = !superSplChars;
                      });
                    }),
              ],
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

  @override
  Widget build(BuildContext context) {
    final _dbHelper = Provider.of<DatabaseHelper>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: backArrowAppBar(context, "Add Password"),
      body: ListView(
        children: <Widget>[
          AlertTextField(
            controller: _urlController,
            hintText: "URL",
          ),
          AlertTextField(
            controller: _emailController,
            hintText: "Email",
          ),
          AlertPasswordField(
            controller: _passwordController,
            hintText: "Password",
          ),
          Text(
            "OR",
            textAlign: TextAlign.center,
          ),
          Container(
            width: size.width * 0.6,
            alignment: Alignment.center,
            child: TextButton(
              child: Text("Generate a Random Password"),
              onPressed: () {
                _getPassGenParams();

                String randomPassword = generateRandomString(18, 1, "()~`");
                setState(() {
                  _passwordController.text = randomPassword;
                });
              },
            ),
          ),
          CustomElevatedButton(
            text: "Add",
            onPressed: () {
              String url = _urlController.text.toString();
              String email = _emailController.text.toString();
              String password = _passwordController.text.toString();
              String msg = "";

              if (url.isEmpty) {
                if (msg.isEmpty)
                  msg += "Please Enter valid URL";
                else
                  msg += " URL ";
              }

              if (email.isEmpty) {
                if (msg.isEmpty)
                  msg += "Please Enter valid Email";
                else
                  msg += " Email ";
              }

              if (password.isEmpty) {
                if (msg.isEmpty)
                  msg += "Please Enter valid Password";
                else
                  msg += " Password ";
              }

              if (msg.isEmpty) {
                Password pass = new Password(
                  title: url,
                  username: email,
                  password: password,
                );

                addPassword(_dbHelper, pass);
                Navigator.pop(context, true);
              } else {
                showSnackbar(context, msg);
              }
            },
          ),
        ],
      ),
    );
  }
}
