import 'package:flutter/material.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/notes/components/notefab.dart';

class AddNote extends StatefulWidget {
  static const routeName = "AddNote";
  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  // TODO:Validate the Text that is saved.
  @override
  Widget build(BuildContext context) {
    TextEditingController _titleController = new TextEditingController();
    TextEditingController _notesController = new TextEditingController();
    
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  isDense: true,
                  hintText: "Title",
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                controller: _titleController,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    hintText: "Content",
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
                controller: _notesController,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: size.width * 0.4,
            child: NoteFab(
              tag: "save",
              onPressed: () {
                String title = _titleController.text;
                String note = _notesController.text;
                Navigator.pop(
                    context,
                    new Note(
                      title: title,
                      note: note,
                      dateCreated: DateTime.now(),
                    ));
              },
              iconData: Icons.save,
            ),
          ),
          SizedBox(width: size.width * 0.1),
          Container(
            width: size.width * 0.4,
            child: NoteFab(
              tag: "cancel",
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.grey[700],
              iconData: Icons.close,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
