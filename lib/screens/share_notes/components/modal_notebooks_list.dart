import 'package:flutter/material.dart';
import 'package:trunk/constants.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/components/modals.dart';

class ModalNotebooksList extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final bool getNote;

  const ModalNotebooksList({Key key, this.databaseHelper, this.getNote}) : super(key: key);
  @override
  _ModalNotebooksListState createState() => _ModalNotebooksListState();
}

class _ModalNotebooksListState extends State<ModalNotebooksList> {
  List<Notebooks> _notebookList = [
    new Notebooks(name: PASSWORD, createdAt: DateTime.now())
  ];
  bool _noteInitialized = false;

  void updateNotebooks() async {
    Future<List<Notebooks>> notebookListFuture =
        widget.databaseHelper.getNotebookList();
    notebookListFuture.then((notebookList) {
      setState(() {
        _notebookList = _notebookList + notebookList;
        _noteInitialized = true;
      });
    });
  }

  Future<Note> _getNoteModal(Notebooks notebook) {
    return getNoteModal(context, notebook, widget.databaseHelper);
  }

  @override
  Widget build(BuildContext context) {
    if (!_noteInitialized) {
      updateNotebooks();
    }

    return Container(
      child: ListView.builder(
          itemCount: _notebookList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text("${_notebookList[index].name}"),
                onTap: () async {
                  if(widget.getNote) {
                    Note note = await _getNoteModal(_notebookList[index]);
                    if (note != null) {
                      Navigator.pop(context, note);
                    }
                  } else {
                    Navigator.pop(context, _notebookList[index]);
                  }
                },
              ),
            );
          }),
    );
  }
}