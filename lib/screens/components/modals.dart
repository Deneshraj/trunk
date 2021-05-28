import 'package:flutter/material.dart';
import 'package:trunk/db/db.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/screens/share_notes/components/modal_notebooks_list.dart';
import 'package:trunk/screens/share_notes/components/modal_notes_list.dart';

import 'modals_keys_list.dart';

Future<Map<String, dynamic>> getKeyToEncryptModal(
    BuildContext context, DatabaseHelper databaseHelper) {
  return showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return ModalKeysList(databaseHelper: databaseHelper);
    },
  );
}

Future<Note> getNotebookModal(
    BuildContext context, DatabaseHelper databaseHelper) async {
  return await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return ModalNotebooksList(
        databaseHelper: databaseHelper,
        getNote: true,
      );
    },
  );
}

Future<Notebooks> getNotebookOnlyModal(
    BuildContext context, DatabaseHelper databaseHelper) async {
  return await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return ModalNotebooksList(
        databaseHelper: databaseHelper,
        getNote: false,
      );
    },
  );
}

Future<Note> getNoteModal(
    BuildContext context, Notebooks notebook, DatabaseHelper databaseHelper) {
  return showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return ModalNotesList(
        databaseHelper: databaseHelper,
        notebook: notebook,
      );
    },
  );
}
