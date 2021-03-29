import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trunk/db.dart';
import 'package:trunk/screens/components/snackbar.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/notes/components/editnote.dart';

import '../../constants.dart';

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
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

  void updateNotes(DatabaseHelper databaseHelper, int notebookId) {
    Future<List<Note>> notesListFuture = databaseHelper.getNotesList(notebookId);
    notesListFuture.then((notesList) {
      setState(() {
        notes = notesList;
        _initialized = true;
      });
    }).catchError((error) => print(error));
  }

  void addNote(DatabaseHelper databaseHelper, Note note) async {
    int result = await databaseHelper.insertNote(note);

    if (result != 0) {
      showSnackbar(context, "Noted Created Successfully!");
      updateNotes(databaseHelper, note.notebookId);
    } else {
      showSnackbar(context, "Failed to create Note!");
    }
  }

  void editNote(DatabaseHelper databaseHelper, Note note, int index) async {
    int result = await databaseHelper.updateNote(note);

    if (result != 0) {
      showSnackbar(context, "Noted Updated Successfully!");
      updateNotes(databaseHelper, note.notebookId);
    } else {
      showSnackbar(context, "Failed to update Note!");
    }
  }

  void optionsAction(DatabaseHelper databaseHelper, String option) {
    if (option == DELETE) {
      Note note = notes[_selected];
      databaseHelper.deleteNote(note);
      setState(() {
        notes.removeAt(_selected);
        _appBar = _defaultBar;
      });
    } else if (option == SHARE_WITH_FRIEND) {
      print("Sharing With Friend");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int _notebookId = ModalRoute.of(context).settings.arguments;
    print("$_notebookId");
    final databaseHelper = Provider.of<DatabaseHelper>(context);

    if (!_initialized) {
      updateNotes(databaseHelper, _notebookId);
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
            optionsAction(databaseHelper, string);
          },
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
      backgroundColor: Colors.deepPurple,
    );
    return Scaffold(
      appBar: _appBar,
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => Card(
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: ListTile(
            title: Text(notes[index].title),
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
                editNote(databaseHelper, result, index);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Navigator.pushNamed(context, '/addnote', arguments: _notebookId).then((result) {
            if (result != null) {
              Note resultNote = result;
              // TODO:validate result for null values
              addNote(databaseHelper, result);
            }
          });
        },
        label: Text("Note"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
