class Notebooks {
  // TODO: Add required and not null constraints
  int id;
  String name;
  DateTime createdAt;

  Notebooks({ this.name, this.createdAt });
  Notebooks.withId({ this.id, this.name, this.createdAt });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['created_at'] = createdAt.toString();

    return map;
  }

  Notebooks.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.createdAt = DateTime.parse(map['created_at']);
  }

}