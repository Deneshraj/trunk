import 'package:flutter/material.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/decrypt_note/components/display_note_row.dart';

class DisplayNote extends StatelessWidget {
  final Note note;

  const DisplayNote({Key key, this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DisplayNoteRow(title: "Title", value: note.title),
        DisplayNoteRow(title: "Note", value: note.note),
        DisplayNoteRow(
            title: "Date Created", value: note.dateCreated.toIso8601String()),
      ],
    );
  }
}