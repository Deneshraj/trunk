import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/utils/file_encrypt.dart';
import 'model/keys.dart';
import 'model/note.dart';

// TODO:Change the database from sqlite to hive
// TODO:Validate all values (passed as arguments)

class DatabaseHelper extends ChangeNotifier {
  static DatabaseHelper _databaseHelper;
  
  String dbFileName = "trunk.db";
  String notebook = "notebook";
  String password = "password";
  String notes = "notes";
  String keys = "keys";
  String friends = "friends";
  int version = 1;
  String key;
  
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);

    var _db = await openDatabase(path, version: version, onCreate: _createDb);
    
    return _db;
  }
  
  Future<Database> _initDb(String path) async {
    var _db = await openDatabase(path, version: version, onCreate: _createDb);
    
    return _db;
  }

  void setKey(String key) {
    this.key = key;
  }

  Future<void> _encryptDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);
    FileEncrypt crypt = FileEncrypt(password: key);
    crypt.encryptFile(path);
    // File file = File(path);
    // file.writeAsString(encryptedText);
  }

  Future<Database> _decryptDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);
    
    FileEncrypt crypt = FileEncrypt(password: key);
    crypt.decryptFile(path);
    return _initDb(path);
  }

  void _deleteDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbFileName);

    await deleteDatabase(path);
  }

  Future<void> _createDb(Database db, int newVersion) async {
    await db.execute("CREATE TABLE IF NOT EXISTS $notebook(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name VARCHAR(255) NOT NULL, created_at VARCHAR(255) NOT NULL);");
    await db.execute("CREATE TABLE IF NOT EXISTS $password(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, url VARCHAR(255) NOT NULL, username TEXT NOT NULL, password TEXT NOT NULL);");
    await db.execute("CREATE TABLE IF NOT EXISTS $notes(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, note TEXT NOT NULL, date_created TEXT NOT NULL, notebook_id INT NOT NULL, FOREIGN KEY(notebook_id) REFERENCES $notebook(id));");
    await db.execute("CREATE TABLE IF NOT EXISTS $keys (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, pub_key TEXT NOT NULL, priv_key TEXT NOT NULL, date_created TEXT NOT NULL)");
    await db.execute("CREATE TABLE IF NOT EXISTS $friends (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(255) NOT NULL, key TEXT NOT NULL, date_created TEXT NOT NULL)");
  }

  void updateDb() async {
    _deleteDb();
    Database db = await initDb();
    await db.execute("CREATE TABLE IF NOT EXISTS $notebook(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name VARCHAR(255) NOT NULL);");
    await db.execute("CREATE TABLE IF NOT EXISTS $password(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, url VARCHAR(255) NOT NULL, username TEXT NOT NULL, password TEXT NOT NULL);");
    await db.execute("CREATE TABLE IF NOT EXISTS $notes(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, note TEXT NOT NULL, date_created TEXT NOT NULL, notebook_id INT NOT NULL, FOREIGN KEY(notebook_id) REFERENCES $notebook(id));");
    await db.execute("CREATE TABLE IF NOT EXISTS $keys (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, pub_key TEXT NOT NULL, priv_key TEXT NOT NULL,date_created TEXT NOT NULL)");
    await db.execute("CREATE TABLE IF NOT EXISTS $friends (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(255) NOT NULL, key TEXT NOT NULL, date_created TEXT NOT NULL)");
  }

  // CRUD Operations for Notebook
  Future<List<Map<String, dynamic>>> getNotebookMapList() async {
    // TODO: Add a method for secure operation.
    Database db = await _decryptDatabase();
    var result = await db.query(notebook, orderBy: 'id ASC');
    // db.rawQuery("SELECT * FROM $notebook ORDER BY id ASC;");
    await _encryptDatabase();
    return result;
  }

  Future<List<Notebooks>> getNotebookList() async {
    var notebookMapList = await getNotebookMapList();
    int count = notebookMapList.length;
    
    List<Notebooks> notebookList = [];

    for(int i = 0; i < count; i++) {
      notebookList.add(Notebooks.fromMapObject(notebookMapList[i]));
    }

    return notebookList;
  }

  Future<int> insertNoteBook(Notebooks nb) async{
    Database db = await _decryptDatabase();
    var result = await db.insert(notebook, nb.toMap());
    await _encryptDatabase();
    
    return result;
  }

  Future<int> deleteNotebook(Notebooks nb) async {
    Database db = await _decryptDatabase();
    var result;
    if(db != null) {
      result = await db.delete(notebook, where: "id = '${nb.id}'");
    }

    await _encryptDatabase();
    return result;
  }

  // CRUD Operations for Notes
  Future<List<Map<String, dynamic>>> getNotesMapList(int notebookId) async {
    Database db = await _decryptDatabase();
    var result = await db.query(notes, where: "notebook_id = '$notebookId'", orderBy: 'id ASC');
    await _encryptDatabase();

    return result;
  }

  Future<List<Note>> getNotesList(int notebookId) async {
    var notesMapList = await getNotesMapList(notebookId);
    int count = notesMapList.length;
    
    List<Note> notesList = [];

    for(int i = 0; i < count; i++) {
      notesList.add(Note.fromMapObject(notesMapList[i]));
    }

    return notesList;
  }

  Future<int> insertNote(Note note) async {
    Database db = await _decryptDatabase();
    print("${note.title}");
    var result = await db.insert(notes, note.toMap());
    await _encryptDatabase();
    return result;
  }

  Future<int> updateNote(Note note) async {
    Database db = await _decryptDatabase();
    var result = await db.update(notes, note.toMap(), where: "id = '${note.id}'");
    await _encryptDatabase();
    return result;
  }
 
  Future<int> deleteNote(Note note) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(notes, where: "id = '${note.id}'");
    await _encryptDatabase();
    return result;
  }

  Future<int> deleteNoteByTitle(Note note) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(notes, where: "title = '${note.title}'");
    await _encryptDatabase();
    return result;
  }

  // CRUD Operations for Passwords
  Future<List<Map<String, dynamic>>> getPasswordsMapList() async {
    Database db = await _decryptDatabase();
    var result = await db.query(password, orderBy: 'id ASC');
    await _encryptDatabase();
    
    return result;
  }

  Future<List<Password>> getPasswordsList() async {
    var passwordsMapList = await getPasswordsMapList();
    int count = passwordsMapList.length;
    
    List<Password> passwordsList = [];
    for(int i = 0; i < count; i++) {
      passwordsList.add(Password.fromMapObject(passwordsMapList[i]));
    }

    return passwordsList;
  }

  Future<int> insertPassword(Password pass) async {
    Database db = await _decryptDatabase();
    var result = await db.insert(password, pass.toMap());
    await _encryptDatabase();
    return result;
  }

  Future<int> updatePassword(Password pass) async {
    Database db = await _decryptDatabase();
    var result = await db.update(password, pass.toMap(), where: "id = '${pass.id}'");
    await _encryptDatabase();
    return result;
  }
 
  Future<int> deletePassword(Password pass) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(password, where: "id = '${pass.id}'");
    await _encryptDatabase();
    return result;
  }

  Future<int> deletePasswordByTitle(Password pass) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(password, where: "title = '${pass.title}'");
    await _encryptDatabase();
    return result;
  }

  // CRUD Operations for Keys
  Future<List<Map<String, dynamic>>> getKeysMapList() async {
    Database db = await _decryptDatabase();
    db.execute("CREATE TABLE IF NOT EXISTS $keys (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, pub_key TEXT NOT NULL, priv_key TEXT NOT NULL,date_created TEXT NOT NULL)");
    var result = await db.query(keys, orderBy: 'id ASC');
    await _encryptDatabase();

    return result;
  }

  Future<List<Keys>> getKeysList() async {
    var keysList = await getKeysMapList();
    int count = keysList.length;

    List<Keys> keys = [];

    keysList.forEach((element) {
      keys.add(Keys.fromMapObject(element));
    });

    return keys;
  }

  Future<int> insertKey(Keys key) async {
    Database db = await _decryptDatabase();
    var result = await db.insert(keys, key.toMap());
    await _encryptDatabase();
    return result;
  }

  Future<int> updateKey(Keys key) async {
    Database db = await _decryptDatabase();
    var result = await db.update(keys, key.toMap(), where: "id = '${key.id}'");
    await _encryptDatabase();
    return result;
  }
 
  Future<int> deleteKey(Keys key) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(keys, where: "id = '${key.id}'");
    await _encryptDatabase();
    return result;
  }

  Future<int> deleteKeyByTitle(Keys key) async {
    Database db = await _decryptDatabase();
    var result = await db.delete(keys, where: "title = '${key.title}'");
    await _encryptDatabase();
    return result;
  }
}