class Password {
  int id;
  String title;
  String username;
  String password;

  Password({ this.title, this.username, this.password });

  Password.withId({ this.id, this.title, this.username, this.password });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map<String,dynamic>();
    if(id != null) {
      map['id'] = id;
    }
    map['url'] = title;
    map['username'] = username;
    map['password'] = password;

    return map;
  }

  Password.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['url'];
    this.username = map['username'];
    this.password = map['password'];
  }
}