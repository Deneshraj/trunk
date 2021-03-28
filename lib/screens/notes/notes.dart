import 'package:flutter/material.dart';
import 'package:trunk/screens/notes/components/addnote.dart';
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

  void changeAppbarToDefault() {
    setState(() {
      _appBar = _defaultBar;
    });
  }

  List<Note> notes = [];

  void optionsAction(String option) {
    if (option == DELETE) {
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
          onSelected: optionsAction,
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
                setState(() {
                  notes[index] = result;
                });
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNote(),
            ),
          );
          if (result != null) {
            setState(() {
              notes.add(result);
            });
          }
        },
        label: Text("Note"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
