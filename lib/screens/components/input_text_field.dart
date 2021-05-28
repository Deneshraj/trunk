import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trunk/constants.dart';

class InputTextField extends StatefulWidget {
  final Function onSubmitted;
  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool autoFocus;
  final bool obscureText;
  final List<TextInputFormatter> inputFormatters;

  const InputTextField({
    Key key,
    this.onSubmitted,
    this.controller,
    this.hintText,
    this.textInputAction = TextInputAction.go,
    this.autoFocus = true,
    this.obscureText = false, this.keyboardType = TextInputType.text, this.inputFormatters,
  }) : super(key: key);
  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool _obsText;
  void toggleVisibility() {
    setState(() {
      _obsText = !_obsText;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _obsText = widget.obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obsText,
      autofocus: widget.autoFocus,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        isDense: true,
        hintText: widget.hintText,
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: 4.5, color: Colors.grey[400]),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 5, color: kPrimaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
        suffixIcon: (widget.obscureText != null && widget.obscureText)
            ? GestureDetector(
                onTap: () {
                  toggleVisibility();
                },
                child:
                    Icon((_obsText) ? Icons.visibility : Icons.visibility_off),
              )
            : null,
      ),
      style: TextStyle(
        fontSize: 18,
        fontFamily: "mulish",
        fontWeight: FontWeight.w500,
      ),

      controller: widget.controller,
    );
  }
}
