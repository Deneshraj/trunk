import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:trunk/db/random_names.dart';
import 'package:trunk/model/friends.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/utils/file_encrypt.dart';

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
  FileEncrypt _cipher;
  
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<void> createDbFile() async {
    String path = await getDbPath(dbFileName);
    File file = File(path);
    bool fileExist = await file.exists();
    if(!fileExist) {
      await File(path).create(recursive: true);
    }
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

  Future<Database> _initNotebookDb(String path) async {
    var _db = await openDatabase(path, version: version, onCreate: _createNotebookDb);
    return _db;
  }

  void setKey(String key) {
    _cipher = FileEncrypt(key);
  }

  Future<String> getDbPath(String fileName) async {
    var databasesPath = await getDatabasesPath();
    return join(databasesPath, fileName);
  }

  Future<void> _encryptDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);
    _cipher.encryptFile(path);
    // File file = File(path);
    // file.writeAsString(encryptedText);
  }

  Future<void> _encryptNotebookDb(Database db, String filename) async {
    // await db.close();
    print("Encrypting db...");
  }

  Future<Database> _decryptDb() async {
    String path = await getDbPath(dbFileName);
    
    _cipher.decryptFile(path);
    return _initDb(path);
  }

  Future<Database> _decryptNotebookDb(String fileName) async {
    String path = await getDbPath(fileName);
    return _initNotebookDb(path);
  }

  void _deleteDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, dbFileName);

    await deleteDatabase(path);
  }

  Future<void> _createDb(Database db, int newVersion) async {
    await db.execute(
          "CREATE TABLE IF NOT EXISTS $notebook(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name VARCHAR(255) NOT NULL, file_name VARCHAR(255) NOT NULL UNIQUE, created_at VARCHAR(255) NOT NULL);");
      await db.execute(
          "CREATE TABLE IF NOT EXISTS $password(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, url VARCHAR(255) NOT NULL, username TEXT NOT NULL, password TEXT NOT NULL);");
      await db.execute(
          "CREATE TABLE IF NOT EXISTS $keys (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL UNIQUE, pub_key TEXT NOT NULL, priv_key TEXT NOT NULL, date_created VARCHAR(255) NOT NULL)");
      await db.execute(
          "CREATE TABLE IF NOT EXISTS $friends (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(255) NOT NULL, key TEXT NOT NULL, title TEXT NOT NULL, date_created VARCHAR(255) NOT NULL)");
  }

  Future<void> _createNotebookDb(Database db, int newVersion) async {
    if(db != null) {
      await db.execute("CREATE TABLE IF NOT EXISTS $notes(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title VARCHAR(255) NOT NULL, note VARCHAR(255) NOT NULL, date_created VARCHAR(255) NOT NULL);");
    }
  }

  void updateDb() async {
    _deleteDb();
    Database db = await initDb();
    _createDb(db, version + 1);
  }

  Future<void> _createDbFile(String fname) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, fname);
    await File(path).create(recursive: true);
  }

  Future<FileSystemEntity> _deleteDbFile(String dbFile) async {
    try {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, dbFile);
      File file = File(path);
      return file.delete(recursive: true);
    } catch (e, s) {
      print("Exception caught $e");
    }

    return null;
  }

  Future<String> _generateUniqueFileName() async {
    bool fileUnique = false;
    String fileName;

    while (!fileUnique) {
      fileName = getRandomString(7) + ".db";
      List<Map<String, dynamic>> map = await getNotebooksByFileName(fileName);

      if (map.isEmpty) {
        fileUnique = true;
        break;
      }
    }
    return fileName;
  }

  // CRUD Operations for notebook
  Future<List<Map<String, dynamic>>> getNotebookMapList() async {
    // TODO: Add a method for secure operation.
    Database db = await _decryptDb();
    if (db != null) {
      var result = await db.query(notebook, orderBy: 'id ASC');
      await _encryptDb();

      return result;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getNotebooksByFileName(String name) async {
    Database db = await _decryptDb();
    var res = await db.query(notebook, where: "file_name = '$name'");
    await _encryptDb();

    return res;
  }

  Future<List<Notebooks>> getNotebookList() async {
    var notebookMapList = await getNotebookMapList();
    if (notebookMapList != null) {
      int count = notebookMapList.length;

      List<Notebooks> notebookList = [];

      for (int i = 0; i < count; i++) {
        notebookList.add(Notebooks.fromMapObject(notebookMapList[i]));
      }

      return notebookList;
    }

    return [];
  }

  Future<int> insertNotebook(Notebooks nb) async {
    Database db = await _decryptDb();
    String fileName = await _generateUniqueFileName();
    nb.fileName = fileName;

    var result = await db.insert(notebook, nb.toMap());
    await _createDbFile(fileName);
    await _encryptDb();

    return result;
  }

  Future<int> deleteNotebook(Notebooks nb) async {
    Database db = await _decryptDb();
    var entity = await _deleteDbFile(nb.fileName);
    var result;

    if (entity != null) {
      if (db != null) {
        result = await db.delete(notebook, where: "id = '${nb.id}'");
      }
    } else {
      result = 1;
    }
    await _encryptDb();

    return result;
  }

  // CRUD Operations for Notes
  Future<List<Map<String, dynamic>>> getNotesMapList(Notebooks notebook) async {
    if (notebook.fileName != null) {
      Database db = await _decryptNotebookDb(notebook.fileName);
      var result = await db.query(notes, orderBy: 'id ASC');
      await _encryptNotebookDb(db, notebook.fileName);

      return result;
    }

    return null;
  }

  Future<List<Note>> getNotesList(Notebooks notebook) async {
    var notesMapList = await getNotesMapList(notebook);
    if (notesMapList != null) {
      int count = notesMapList.length;

      List<Note> notesList = [];
      for (int i = 0; i < count; i++) {
        notesList.add(Note.fromMapObject(notesMapList[i]));
      }

      return notesList;
    }

    return null;
  }

  Future<int> insertNote(Note note, Notebooks nb) async {
    Database db = await _decryptNotebookDb(nb.fileName);
    var result = await db.insert(notes, note.toMap());
    await _encryptNotebookDb(db, nb.fileName);

    return result;
  }

  Future<int> updateNote(Note note, Notebooks notebook) async {
    Database db = await _decryptNotebookDb(notebook.fileName);
    var result =
        await db.update(notes, note.toMap(), where: "id = '${note.id}'");
    await _encryptNotebookDb(db, notebook.fileName);

    return result;
  }

  Future<int> deleteNote(Note note, Notebooks notebook) async {
    Database db = await _decryptNotebookDb(notebook.fileName);
    var result = await db.delete(notes, where: "id = '${note.id}'");
    await _encryptNotebookDb(db, notebook.fileName);

    return result;
  }

  Future<int> deleteNoteByTitle(Note note, Notebooks notebook) async {
    Database db = await _decryptNotebookDb(notebook.fileName);
    var result = await db.delete(notes, where: "title = '${note.title}'");
    await _encryptNotebookDb(db, notebook.fileName);

    return result;
  }

  // CRUD Operations for Passwords
  Future<List<Map<String, dynamic>>> getPasswordsMapList() async {
    Database db = await _decryptDb();
    var result = await db.query(password, orderBy: 'id ASC');
    await _encryptDb();

    return result;
  }

  Future<List<Password>> getPasswordsList() async {
    var passwordsMapList = await getPasswordsMapList();
    int count = passwordsMapList.length;

    List<Password> passwordsList = [];
    for (int i = 0; i < count; i++) {
      passwordsList.add(Password.fromMapObject(passwordsMapList[i]));
    }

    return passwordsList;
  }

  Future<int> insertPassword(Password pass) async {
    Database db = await _decryptDb();
    var result = await db.insert(password, pass.toMap());
    await _encryptDb();

    return result;
  }

  Future<int> updatePassword(Password pass) async {
    Database db = await _decryptDb();
    var result =
        await db.update(password, pass.toMap(), where: "id = '${pass.id}'");
    await _encryptDb();

    return result;
  }

  Future<int> deletePassword(Password pass) async {
    Database db = await _decryptDb();
    var result = await db.delete(password, where: "id = '${pass.id}'");
    await _encryptDb();

    return result;
  }

  Future<int> deletePasswordByTitle(Password pass) async {
    Database db = await _decryptDb();
    var result = await db.delete(password, where: "title = '${pass.title}'");
    await _encryptDb();

    return result;
  }

  // CRUD Operations for Keys
  Future<List<Map<String, dynamic>>> getKeysMapList() async {
    Database db = await _decryptDb();
    db.execute(
        "CREATE TABLE IF NOT EXISTS $keys (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title VARCHAR(255) NOT NULL, pub_key TEXT NOT NULL, priv_key TEXT NOT NULL,date_created TEXT NOT NULL)");
    var result = await db.query(keys, orderBy: 'id ASC');
    await _encryptDb();

    return result;
  }

  Future<List<Keys>> getKeysList() async {
    var keysList = await getKeysMapList();

    List<Keys> keys = [];

    keysList.forEach((element) {
      keys.add(Keys.fromMapObject(element));
    });

    return keys;
  }

  Future<Keys> getKeyByTitle(String title) async {
    Database db = await _decryptDb();
    var result = await db.query(keys, where: "title = '$title'");
    await _encryptDb();

    return Keys.fromMapObject(result[0]);
  }

  Future<int> insertKey(Keys key) async {
    Database db = await _decryptDb();
    var result = await db.insert(keys, key.toMap());
    await _encryptDb();

    return result;
  }

  Future<int> updateKey(Keys key) async {
    Database db = await _decryptDb();
    var result = await db.update(keys, key.toMap(), where: "id = '${key.id}'");
    await _encryptDb();

    return result;
  }

  Future<int> deleteKey(Keys key) async {
    Database db = await _decryptDb();
    var result = await db.delete(keys, where: "id = '${key.id}'");
    await _encryptDb();

    return result;
  }

  Future<int> deleteKeyByTitle(Keys key) async {
    Database db = await _decryptDb();
    var result = await db.delete(keys, where: "title = '${key.title}'");
    await _encryptDb();

    return result;
  }

  // CRUD Operations for Friends List
  Future<List<Map<String, dynamic>>> getFriendsMapList() async {
    Database db = await _decryptDb();
    var result = await db.query(friends, orderBy: 'id ASC');
    await _encryptDb();

    return result;
  }

  Future<List<Friend>> getFriendsList() async {
    var friendsMapList = await getFriendsMapList();

    List<Friend> friendsList = [];

    friendsMapList.forEach((element) {
      friendsList.add(Friend.fromMapObject(element));
    });

    return friendsList;
  }

  Future<int> insertFriend(Friend friend) async {
    Database db = await _decryptDb();
    var result = await db.insert(friends, friend.toMap());
    await _encryptDb();

    return result;
  }

  Future<int> insertFriendMap(Map<String, dynamic> friendMap) async {
    Database db = await _decryptDb();
    var result = await db.insert(friends, friendMap);
    await _encryptDb();

    return result;
  }

  Future<int> updateFriend(Friend friend) async {
    Database db = await _decryptDb();
    var result =
        await db.update(friends, friend.toMap(), where: "id = '${friend.id}'");
    await _encryptDb();

    return result;
  }

  Future<int> deleteFriend(Friend friend) async {
    Database db = await _decryptDb();
    var result = await db.delete(friends, where: "id = ${friend.id}");
    await _encryptDb();

    return result;
  }

  Future<int> deleteFriendByName(Friend friend) async {
    Database db = await _decryptDb();
    var result = await db.delete(friends, where: "name = '${friend.name}'");
    await _encryptDb();

    return result;
  }
}