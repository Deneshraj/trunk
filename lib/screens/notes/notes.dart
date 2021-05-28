import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/modals.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/notes/components/addnote.dart';
import 'package:trunk/screens/notes/components/editnote.dart';
import 'package:trunk/utils/encrypt_note.dart';

import '../../constants.dart';

class Notes extends StatefulWidget {
  static const routeName = "Notes";
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<String> _options = [
    DELETE,
    SHARE_WITH_FRIEND,
  ];

  // TODO:Add Modal to view notes
  static final AppBar _defaultBar = AppBar(
    title: Text("Notes"),
  );
  AppBar _appBar = _defaultBar;
  int _selected;
  List<Note> notes = [];
  bool _initialized = false;

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
    });
  }

  void updateNotes(DatabaseHelper databaseHelper, Notebooks notebook) {
    Future<List<Note>> notesListFuture = databaseHelper.getNotesList(notebook);
    notesListFuture.then((notesList) {
      setState(() {
        notes = notesList;
        _initialized = true;
      });
    }).catchError((error) => print(error));
  }

  void addNote(
      DatabaseHelper databaseHelper, Note note, Notebooks notebook) async {
    int result = await databaseHelper.insertNote(note, notebook);

    if (result != 0) {
      showSnackbar(context, "Noted Created Successfully!");
      updateNotes(databaseHelper, notebook);
    } else {
      showSnackbar(context, "Failed to create Note!");
    }
  }

  void editNote(DatabaseHelper databaseHelper, Note note, Notebooks nb) async {
    int result = await databaseHelper.updateNote(note, nb);

    if (result != 0) {
      showSnackbar(context, "Noted Updated Successfully!");
      updateNotes(databaseHelper, nb);
    } else {
      showSnackbar(context, "Failed to update Note!");
    }
  }

  void optionsAction(
    BuildContext context,
    DatabaseHelper databaseHelper,
    String option,
    Notebooks nb,
  ) async {
    if (option == DELETE) {
      Note note = notes[_selected];
      databaseHelper.deleteNote(note, nb);
      setState(() {
        notes.removeAt(_selected);
        _appBar = _defaultBar;
      });
    } else if (option == SHARE_WITH_FRIEND) {
      Note note = notes[_selected];
      Map<String, dynamic> publicKey =
          await _getKeyToEncryptModal(context, databaseHelper);

      if (publicKey != null) {
        String path = await encryptNote(publicKey, note);
        if (path != null) {
          await Share.shareFiles([
            path,
          ]);
          setState(() {
            _appBar = _defaultBar;
          });
        } else {
          print("Path is null");
          showSnackbar(context, "Unable to share");
        }
      } else {
        showSnackbar(context, "Please select a key to Encrypt");
      }
    }
  }

  Future<Map<String, dynamic>> _getKeyToEncryptModal(
      BuildContext context, DatabaseHelper databaseHelper) {
    return getKeyToEncryptModal(context, databaseHelper);
  }

  @override
  Widget build(BuildContext context) {
    final Notebooks _notebook = ModalRoute.of(context).settings.arguments;
    final databaseHelper = Provider.of<DatabaseHelper>(context);

    if (_notebook.fileName == null) {
      Navigator.of(context).pop();
    }

    if (!_initialized && _notebook.fileName != null) {
      updateNotes(databaseHelper, _notebook);
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
            optionsAction(context, databaseHelper, string, _notebook);
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
    return Scaffold(
      appBar: _appBar,
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              notes[index].title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onLongPress: () {
              setState(() {
                _appBar = _selectBar;
                _selected = index;
              });
            },
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNote(note: notes[index]),
                ),
              );

              if (result != null) {
                editNote(databaseHelper, result, _notebook);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.pushNamed(context, AddNote.routeName).then((result) {
            if (result != null) {
              Note resultNote = result;
              if(resultNote.title.isNotEmpty && resultNote.note.isNotEmpty) {
                addNote(databaseHelper, result, _notebook);
              } else {
                showSnackbar(context, "Title and Note should not be empty");
              }
            } else {
              showSnackbar(context, "Note not added!");
            }
          }).catchError((err) => print(err));
        },
        label: Text("Note"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
