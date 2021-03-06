import 'package:flutter/material.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/screens/notes/components/notefab.dart';

class EditNote extends StatefulWidget {
  static const routeName = "EditNote";
  final Note note;

  const EditNote({Key key, this.note}) : super(key: key);

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  FocusNode myFocusNode;
  bool _enabled = false;
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _notesController = new TextEditingController();

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
    setState(() {
      _titleController.text = widget.note.title;
      _notesController.text = widget.note.note;
    });

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      body: Column(
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
          Expanded(
            child: ListView(
              children: <Widget>[
                TextField(
                  enabled: _enabled,
                  focusNode: myFocusNode,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    isDense: true,
                    hintText: "Content",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  controller: _notesController,
                  style: TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: size.width * 0.4,
                child: NoteFab(
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
                        new Note.withId(
                          id: widget.note.id,
                          title: _titleController.text,
                          note: _notesController.text,
                          dateCreated: DateTime.now(),
                        ),
                      );
                    }
                  },
                  iconData: Icons.edit,
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
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
