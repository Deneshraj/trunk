import 'package:flutter/material.dart';

class Notebooks {
  int id;
  String name;
  String fileName;
  DateTime createdAt;

  Notebooks({ @required this.name, @required this.createdAt });
  Notebooks.withId({ @required this.id, @required this.name, @required this.createdAt });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }

    if(fileName != null) {
      map['file_name'] = fileName;
    } else throw Exception("File name should not be null");

    if(name != null) {
      map['name'] = name;
    } else throw Exception("Name Should not be null");

    if(createdAt != null) {
      map['created_at'] = createdAt.toString();
    } else throw Exception("Created At Should not be null");

    return map;
  }

  Notebooks.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.fileName = map['file_name'];
    this.createdAt = DateTime.parse(map['created_at']);
  }

}