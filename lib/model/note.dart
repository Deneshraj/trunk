class Note {
  int id;
  int notebookId;
  String title;
  String note;
  DateTime dateCreated;

  Note({ this.title, this.note, this.dateCreated, this.notebookId });
  Note.withId({ this.id, this.notebookId, this.title, this.note, this.dateCreated });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['notebook_id'] = notebookId;
    map['title'] = title;
    map['note'] = note;
    map['date_created'] = dateCreated.toString();

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.notebookId = map['notebook_id'];
    this.title = map['title'];
    this.note = map['note'];
    this.dateCreated = DateTime.parse(map['date_created']);
  }
}
