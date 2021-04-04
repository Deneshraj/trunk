import 'package:flutter/material.dart';
import 'package:trunk/screens/components/input_files_button.dart';

class ShareNoteWithSteg extends StatefulWidget {
  static const routeName = "ShareNoteWithSteg";
  @override
  _ShareNoteWithStegState createState() => _ShareNoteWithStegState();
}

class _ShareNoteWithStegState extends State<ShareNoteWithSteg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share note with Steganography"),),
      body: Container(
        child: InputFilesButton(
          text: "Enter the ",
        ),
      ),
    );
  }
}