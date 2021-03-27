import 'package:flutter/material.dart';
import 'package:trunk/model/note.dart';

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<String> notes = [];

  Future<Note> addNote(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter New Note"),
        content: Container(
          height: 200,
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    hintText: "Enter the Title",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
                  ),
                  controller: titleController,
                ),
              ),
              Expanded(
                child: TextField(
                  autofocus: true,
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    hintText: "Enter the Content",
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
                  ),
                  controller: contentController,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Add"),
            onPressed: () {
              String value = titleController.text.toString();
              if (value.isNotEmpty) {
                Note note = Note(value, contentController.text.toString());
                Navigator.of(context).pop(note);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please Enter a Valid Note")),
                );
                Navigator.of(context).pop();
              }
            },
          ),
          MaterialButton(
            elevation: 5.0,
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => Card(
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: ListTile(
            title: Text(notes[index]),
            onTap: () {
              print("${notes[index]}");
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNote(context).then((note) {
            setState(() {
              notes.add(note.title);
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList({
    Key key,
    this.note,
  }) : super(key: key);

  final String note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("$note");
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(note),
        ),
      ),
    );
  }
}
