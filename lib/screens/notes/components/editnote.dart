import 'package:flutter/material.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/notes/components/notefab.dart';

class EditNote extends StatefulWidget {
  final Note note;

  const EditNote({Key key, this.note}) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  FocusNode myFocusNode;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _titleController = new TextEditingController();
    TextEditingController _notesController = new TextEditingController();
    _titleController.text = widget.note.title;
    _notesController.text = widget.note.content;

    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                enabled: _enabled,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  isDense: true,
                  hintText: "Title",
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                controller: _titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              TextField(
                enabled: _enabled,
                focusNode: myFocusNode,
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    hintText: "Content",
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
                controller: _notesController,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          NoteFab(
            tag: (_enabled) ? "save" : "edit",
            onPressed: () {
              if (!_enabled) {
                setState(() {
                  _enabled = true;
                  myFocusNode.requestFocus();
                });
              } else {
                Navigator.pop(
                  context,
                  new Note(
                    _titleController.text,
                    _notesController.text,
                  ),
                );
              }
            },
            iconData: Icons.edit,
          ),
          NoteFab(
            tag: "cancel",
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.grey[700],
            iconData: Icons.close,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}