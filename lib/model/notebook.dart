class Notebooks {
  // TODO: Add required and not null constraints
  int id;
  String name;
  String fileName;
  DateTime createdAt;

  Notebooks({ this.name, this.createdAt });
  Notebooks.withId({ this.id, this.name, this.createdAt });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }

    if(fileName != null) {
      map['file_name'] = fileName;
    } else throw Exception("File name should not be null");

    map['name'] = name;
    map['created_at'] = createdAt.toString();

    return map;
  }

  Notebooks.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.fileName = map['file_name'];
    this.createdAt = DateTime.parse(map['created_at']);
  }

}