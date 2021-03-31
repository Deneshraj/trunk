import 'package:flutter/material.dart';

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
        child: Text("Sharing note with Steganography"),
      ),
    );
  }
}