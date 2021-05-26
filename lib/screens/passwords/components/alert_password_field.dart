import 'package:flutter/material.dart';

class AlertPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType textInputType;

  const AlertPasswordField(
      {Key key, this.controller, this.hintText, this.textInputType})
      : super(key: key);

  @override
  _AlertPasswordFieldState createState() => _AlertPasswordFieldState();
}

class _AlertPasswordFieldState extends State<AlertPasswordField> {
  bool _obsText = true;

  void toggleVisibility() {
    setState(() {
      _obsText = !_obsText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        obscureText: _obsText,
        textInputAction: TextInputAction.next,
        keyboardType: widget.textInputType,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            isDense: true,
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0),
              borderRadius: BorderRadius.circular(5),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                toggleVisibility();
              },
              child: Icon((_obsText) ? Icons.visibility : Icons.visibility_off),
            )),
        style: TextStyle(fontSize: 18),
        controller: widget.controller,
      ),
    );
  }
}
