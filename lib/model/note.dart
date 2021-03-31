class Note {
  int id;
  String title;
  String note;
  DateTime dateCreated;

  Note({ this.title, this.note, this.dateCreated });
  Note.withId({ this.id, this.title, this.note, this.dateCreated });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['note'] = note;
    map['date_created'] = dateCreated.toString();

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.note = map['note'];
    this.dateCreated = DateTime.parse(map['date_created']);
  }
}
