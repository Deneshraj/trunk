import 'package:flutter/material.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';

class ModalNotesList extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final Notebooks notebook;

  const ModalNotesList({Key key, this.databaseHelper, this.notebook})
      : super(key: key);
  @override
  _ModalNotesListState createState() => _ModalNotesListState();
}

class _ModalNotesListState extends State<ModalNotesList> {
  List<Note> _notesList = [];
  bool _initialized = false;

  void updateNotes() async {
    Future<List<Note>> notebookListFuture =
        widget.databaseHelper.getNotesList(widget.notebook);
    notebookListFuture.then((notesList) {
      setState(() {
        _notesList = notesList;
        _initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      updateNotes();
    }

    return Container(
      child: ListView.builder(
          itemCount: _notesList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text("${_notesList[index].title}"),
                onTap: () async {
                  Navigator.pop(context, _notesList[index]);
                },
              ),
            );
          }),
    );
  }
}