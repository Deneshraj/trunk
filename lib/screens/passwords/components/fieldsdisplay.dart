import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FieldsDisplay extends StatefulWidget {
  const FieldsDisplay({
    Key key,
    this.name,
    this.value,
    this.isPass = false,
  }) : super(key: key);

  final String name;
  final String value;
  final bool isPass;

  @override
  _FieldsDisplayState createState() => _FieldsDisplayState();
}

class _FieldsDisplayState extends State<FieldsDisplay> {
  bool _visible = true;

  void initState() {
    super.initState();

    if (widget.isPass) _visible = false;
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.name;
    final String value = widget.value;
    final bool _isPass = widget.isPass;

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$name",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          (_isPass && !_visible) ? Text("********") : Text("$value"),
          (_isPass)
              ? InkWell(
                  child: Icon(
                      (_visible) ? (Icons.visibility_off) : (Icons.visibility)),
                  onTap: () {
                    setState(() {
                      _visible = !_visible;
                    });
                  },
                )
              : SizedBox(),
          (_isPass)
              ? InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: "$value"));
                    Fluttertoast.showToast(
                        msg: "Password Copied to Clipboard",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color(0xaa3c4043),
                        textColor: Colors.white,
                        fontSize: 16.0);
                  },
                  child: Icon(Icons.copy),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}