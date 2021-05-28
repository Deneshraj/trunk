import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart' as p;
import 'package:provider/provider.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/screens/components/alertbutton.dart';
import 'package:trunk/screens/components/navdrawer.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/utils/exit_alert.dart';
import 'package:trunk/utils/store_file.dart';
import 'package:share/share.dart';

import '../../constants.dart';
import '../../db/db.dart';

// TODO:Add a Loading Screen while generating keys
// TODO:Change the extension of the key shared.
class UserKey extends StatefulWidget {
  static const routeName = "UserKey";
  @override
  UserKeyState createState() => UserKeyState();
}

class UserKeyState extends State<UserKey> {
  List<String> _options = [
    DELETE,
    SHARE_WITH_FRIEND,
  ];

  List<Keys> keys = [];
  int _selected;
  bool _initialized = false;
  bool _loading = false;
  static final AppBar _defaultBar = AppBar(
    title: Text("Share Key"),
  );

  AppBar _appBar = _defaultBar;

  Future<String> getKeyTitle(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
          return AlertDialog(
            title: Text(
              "New Security Key",
              textAlign: TextAlign.center,
            ),
            content: TextField(
              autofocus: true,
              onSubmitted: (value) {
                if (value.isEmpty) {
                  showSnackbar(context, "Please Enter a valid title!");
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
                hintText: "Title",
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              style: TextStyle(fontSize: 18),
              controller: titleController,
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
                          String value = titleController.text.toString();
                          if (value.isNotEmpty) {
                            Navigator.of(context).pop(value);
                          } else {
                            showSnackbar(context, "Please Enter a valid title!");

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

  Future<void> _shareKey(Map<String, dynamic> keyMap) async {
    String keysJson = jsonEncode(keyMap);
    String filePath = await storeFileLocally("pub.key", "keys", keysJson);
    if (filePath != null) {
      await Share.shareFiles([filePath], text: "Key");
      // deleteFile(filePath);
    } else {
      showSnackbar(context, "An Error occured while sharing");
    }
  }

  // void optionsAction(DatabaseHelper databaseHelper, String option) {
  void optionsAction(String option, DatabaseHelper databaseHelper) async {
    if (option == DELETE) {
      Keys key = keys[_selected];
      deleteKey(databaseHelper, key);
    } else if (option == SHARE_WITH_FRIEND) {
      Map<String, dynamic> keyMap = {
        'key': keys[_selected].publicKeyToString(),
        'title': keys[_selected].title,
      };

      await _shareKey(keyMap);
    }

    setState(() {
      _appBar = _defaultBar;
    });
  }

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
    });
  }

  void updateKeys(DatabaseHelper databaseHelper) async {
    Future<List<Keys>> futureKeysList = databaseHelper.getKeysList();
    futureKeysList.then((keysList) {
      setState(() {
        keys = keysList;
      });
    }).catchError((error) => print(error));
  }

  void addKey(DatabaseHelper databaseHelper, Keys key) async {
    int result = await databaseHelper.insertKey(key);

    if (result != 0) {
      showSnackbar(context, "New Key Created Successfully!");
      updateKeys(databaseHelper);
    } else {
      showSnackbar(context, "Failed to add new Key");
    }
  }

  void deleteKey(DatabaseHelper databaseHelper, Keys key) async {
    int result = await databaseHelper.deleteKey(key);

    if (result != 0) {
      showSnackbar(context, "Key ${key.title} Deleted!");
      updateKeys(databaseHelper);
    } else {
      showSnackbar(context, "Failed to add new Key");
    }
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      updateKeys(databaseHelper);
      _initialized = true;
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
            optionsAction(string, databaseHelper);
          },
          itemBuilder: (BuildContext context) {
            return _options.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList();
          },
        ),
      ],
      backgroundColor: Colors.deepPurple,
    );

    return WillPopScope(
      onWillPop: () => exitAlert(context),
      child: Scaffold(
        appBar: _appBar,
        drawer: NavDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          "${keys[index].title}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () async {
                          Map<String, dynamic> keyMap = {
                            'key': keys[index].publicKeyToString(),
                            'title': keys[index].title,
                          };

                          await _shareKey(keyMap);
                        },
                        onLongPress: () {
                          setState(() {
                            _appBar = _selectBar;
                            _selected = index;
                          });
                        },
                      ),
                    );
                  }),
            ),
            (_loading) ? CircularProgressIndicator() : Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            setState(() {
              _loading = true;
            });
            final title = await getKeyTitle(context);

            if (title != null) {
              try {
                final value =
                    generateRsaKeyPair(generateSecureRandom(), title: title);

                if (value != null) {
                  addKey(databaseHelper, value);
                }
              } catch (e) {
                print("$e");
              }
            }
            setState(() {
              _loading = false;
            });
          },
          label: Text("Generate new key"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Keys generateRsaKeyPair(p.SecureRandom secureRandom,
      {int bitLength = 2048, String title}) {
    final keyGen = p.RSAKeyGenerator()
      ..init(ParametersWithRandom(
          p.RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));
    final pair = keyGen.generateKeyPair();
    final myPublic = pair.publicKey as p.RSAPublicKey;
    final myPrivate = pair.privateKey as p.RSAPrivateKey;
    return Keys(
        title: title,
        publicKey: myPublic,
        privateKey: myPrivate,
        dateCreated: DateTime.now());
  }

  SecureRandom generateSecureRandom() {
    final secureRandom = p.FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }
}
