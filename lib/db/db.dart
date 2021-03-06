import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart';
import 'package:pointycastle/export.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trunk/db/random_names.dart';
import 'package:trunk/model/friends.dart';
import 'package:trunk/model/keys.dart';
import 'package:trunk/model/note.dart';
import 'package:trunk/model/notebook.dart';
import 'package:trunk/model/password.dart';
import 'package:trunk/utils/text_encrypt.dart';

class DatabaseHelper extends ChangeNotifier {
  static DatabaseHelper _databaseHelper;

  String dbFileName = "trunk.db";
  String hashFileName = "password.hash";
  String notebook = "notebook";
  String password = "password";
  String notes = "notes";
  String keys = "keys";
  String friends = "friends";
  int version = 1;
  EncryptText _cipher;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<void> createDbFile() async {
    String path = await getDbPath(dbFileName);
    bool fileExist = await isDbExists();
    if (!fileExist) {
      await File(path).create(recursive: true);
    }
  }

  Future<bool> isDbExists() async {
    String path = await getDbPath(dbFileName);
    File file = File(path);
    return await file.exists();
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
    var _db =
        await openDatabase(path, version: version, onCreate: _createNotebookDb);
    return _db;
  }

  Future<bool> setKey(String key) async {
    var hashedPassword = SHA256Digest().process(
      Uint8List.fromList(key.codeUnits),
    );
    bool hash = await checkHash(hashedPassword);

    if (hash == true) {
      _cipher = EncryptText(
        enc.Key(
          hashedPassword,
        ),
      );
      return true;
    }

    return false;
  }

  Future<bool> checkHash(Uint8List password) async {
    String hashFile = await getHashFile();
    String hashedPassword = String.fromCharCodes(
      SHA256Digest().process(password),
    );
    if (hashFile == null) {
      createHashFile(hashedPassword);
      return true;
    }

    File file = File(hashFile);
    String passToCheck = await file.readAsString();
    if (passToCheck == "") {
      file.writeAsString(hashedPassword);
      return true;
    }

    return (passToCheck == hashedPassword);
  }

  Future<String> getHashFile() async {
    String hashPath = join(await getDatabasesPath(), hashFileName);
    File hashFile = File(hashPath);
    if (await hashFile.exists()) {
      return hashPath;
    }
    return null;
  }

  Future<void> createHashFile(String hashedPassword) async {
    String hashPath = join(await getDatabasesPath(), hashFileName);
    File hashFile = File(hashPath);

    if (!(await hashFile.exists())) {
      hashFile.create(recursive: true);
      hashFile.writeAsString(hashedPassword);
    }
  }

  Future<String> getDbPath(String fileName) async {
    var databasesPath = await getDatabasesPath();
    return join(databasesPath, fileName);
  }

  Future<Database> _openDb({String fileName}) async {
    String fname = (fileName == null) ? dbFileName : fileName;
    String path = await getDbPath(fname);
    return (fileName == null) ? _initDb(path) : _initNotebookDb(path);
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
    if (db != null) {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS $notes(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title VARCHAR(255) NOT NULL, note VARCHAR(255) NOT NULL, date_created VARCHAR(255) NOT NULL);");
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
      print("$s");
    }

    return null;
  }

  Future<String> generateUniqueFileName() async {
    bool fileUnique = false;
    String fileName;

    while (!fileUnique) {
      fileName = getRandomString(7) + ".db";
      List<Map<String, dynamic>> map = await getNotebooksByFileName(_cipher.encryptText(fileName));

      if (map.isEmpty) {
        fileUnique = true;
        break;
      }
    }
    return fileName;
  }

  Map<String, dynamic> _encryptUsingCipher(Map<String, dynamic> map, EncryptText cipher) {
    var encryptedMap = Map<String, dynamic>();

    map.forEach((key, value) {
      if (key == "id")
        encryptedMap[key] = value;
      else
        encryptedMap[key] = cipher.encryptText(map[key]);
    });

    return encryptedMap;
  }

  Map<String, dynamic> _encrypt(Map<String, dynamic> map) {
    return _encryptUsingCipher(map, _cipher);
  }

  Map<String, dynamic> _decryptUsingCipher(Map<String, dynamic> map, EncryptText cipher) {
    var decryptedMap = Map<String, dynamic>();

    map.forEach((key, value) {
      if (key == "id")
        decryptedMap[key] = value;
      else
        decryptedMap[key] = cipher.decryptText(map[key]);
    });

    return decryptedMap;
  }

  Map<String, dynamic> _decrypt(Map<String, dynamic> map) {
    return _decryptUsingCipher(map, _cipher);
  }

  // CRUD Operations for notebook
  Future<List<Map<String, dynamic>>> getNotebookMapList() async {
    Database db = await _openDb();
    if (db != null) {
      var result = await db.query(notebook, orderBy: 'id ASC');
      return result;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getNotebooksByFileName(String name) async {
    Database db = await _openDb();
    var res = await db.query(notebook, where: "file_name = '$name'");

    return res;
  }

  Future<List<Notebooks>> getNotebookList() async {
    var notebookMapList = await getNotebookMapList();
    if (notebookMapList != null) {
      int count = notebookMapList.length;

      List<Notebooks> notebookList = [];

      for (int i = 0; i < count; i++) {
        var currentMap = _decrypt(notebookMapList[i]);
        notebookList.add(Notebooks.fromMapObject(currentMap));
      }

      return notebookList;
    }

    return [];
  }

  Future<Notebooks> getNotebookByName(String name) async {
    Database db = await _openDb();
    var res = await db.query(notebook, where: "name = '${_cipher.encryptText(name)}'");
    
    if(res.length > 0) {
      return Notebooks.fromMapObject(_decrypt(res[0]));
    }

    return null;
  }

  Future<int> insertNotebook(Notebooks nb) async {
    Database db = await _openDb();
    String fileName = await generateUniqueFileName();
    nb.fileName = fileName;

    var result = await db.insert(
      notebook,
      _encrypt(nb.toMap()),
    );
    await _createDbFile(fileName);
    

    return result;
  }

  Future<int> updateNotebook(Notebooks nb) async {
    Database db = await _openDb();
    int res = -1;
    
    // Getting the Notebook from Database
    List<Map> nbIdMap = await db.query(notebook, where: "id = ${nb.id}");
    List<Map> nbNameMap = await db.query(notebook, where: "name = ${nb.name}");

    if(nbNameMap.isEmpty && nbIdMap.isNotEmpty) {
      res = await db.update(notebook, nb.toMap(), where: 'id = ${nb.id}');
    }

    return res;
  }

  Future<int> deleteNotebook(Notebooks nb) async {
    Database db = await _openDb();
    var entity = await _deleteDbFile(nb.fileName);
    var result;

    if (entity != null) {
      if (db != null) {
        result = await db.delete(notebook, where: "id = '${nb.id}'");
      }
    } else {
      result = 1;
    }
    

    return result;
  }

  Future<void> processNotebookForSharing(Notebooks notebook, EncryptText cipher) async {
    if(notebook.fileName.isNotEmpty) {
      var result = await getNotesMapList(notebook);

      for(int i = 0, count = result.length; i < count; i++) {
        Map<String, dynamic> encryptedNote = _encryptUsingCipher(_decrypt(result[i]), cipher);
        updateEncryptedNoteById(encryptedNote, notebook);
      }
    }
  }

  Future<void> openProcessedNotebook(Notebooks notebook, EncryptText cipher) async {
    if(notebook.fileName.isNotEmpty) {
      var result = await getNotesMapList(notebook);

      for(int i = 0, count = result.length; i < count; i++) {
        Map<String, dynamic> encryptedNote = _encrypt(_decryptUsingCipher(result[i], cipher));
        updateEncryptedNoteById(encryptedNote, notebook);
      }
    }
  }

  // CRUD Operations for Notes
  Future<List<Map<String, dynamic>>> getNotesMapList(Notebooks notebook) async {
    if (notebook.fileName != null) {
      Database db = await _openDb(fileName: notebook.fileName);
      var result = await db.query(notes, orderBy: 'id ASC');
      

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
        var currentMap = _decrypt(notesMapList[i]);
        notesList.add(Note.fromMapObject(currentMap));
      }

      return notesList;
    }

    return null;
  }

  Future<int> insertNote(Note note, Notebooks nb) async {
    Database db = await _openDb(fileName: nb.fileName);
    var result = await db.insert(
      notes,
      _encrypt(note.toMap()),
    );
    

    return result;
  }

  Future<int> updateNote(Note note, Notebooks notebook) async {
    Database db = await _openDb(fileName: notebook.fileName);
    var result = await db.update(
      notes,
      _encrypt(note.toMap()),
      where: "id = '${note.id}'",
    );
    

    return result;
  }

  Future<int> updateEncryptedNoteById(Map<String, dynamic> note, Notebooks notebook) async {
    Database db = await _openDb(fileName: notebook.fileName);
    var result = await db.update(
      notes,
      note,
      where: "id = '${note['id']}'",
    );

    return result;
  }

  Future<int> deleteNote(Note note, Notebooks notebook) async {
    Database db = await _openDb(fileName: notebook.fileName);
    var result = await db.delete(notes, where: "id = '${note.id}'");
    

    return result;
  }

  // CRUD Operations for Passwords
  Future<List<Map<String, dynamic>>> getPasswordsMapList() async {
    Database db = await _openDb();
    var result = await db.query(password, orderBy: 'id ASC');
    

    return result;
  }

  Future<List<Password>> getPasswordsList() async {
    var passwordsMapList = await getPasswordsMapList();
    int count = passwordsMapList.length;

    List<Password> passwordsList = [];
    for (int i = 0; i < count; i++) {
      var currentMap = _decrypt(passwordsMapList[i]);
      passwordsList.add(Password.fromMapObject(currentMap));
    }

    return passwordsList;
  }

  Future<int> insertPassword(Password pass) async {
    Database db = await _openDb();
    var result = await db.insert(
      password,
      _encrypt(pass.toMap()),
    );
    

    return result;
  }

  Future<int> updatePassword(Password pass) async {
    Database db = await _openDb();
    var result = await db.update(password, _encrypt(pass.toMap()),
        where: "id = '${pass.id}'");
    

    return result;
  }

  Future<int> deletePassword(Password pass) async {
    Database db = await _openDb();
    var result = await db.delete(password, where: "id = '${pass.id}'");
    

    return result;
  }

  // CRUD Operations for Keys
  Future<List<Map<String, dynamic>>> getKeysMapList() async {
    Database db = await _openDb();
    var result = await db.query(keys, orderBy: 'id ASC');
    

    return result;
  }

  Future<Keys> getFirstKey() async {
    Database db = await _openDb();
    var result = await db.query(keys, orderBy: 'id ASC', limit: 1);

    if (result.length > 0) {
      return Keys.fromMapObject(_decrypt(result[0]));
    }

    return null;
  }

  Future<List<Keys>> getKeysList() async {
    var keysList = await getKeysMapList();

    List<Keys> keys = [];

    keysList.forEach((element) {
      var currentMap = _decrypt(element);
      keys.add(Keys.fromMapObject(currentMap));
    });

    return keys;
  }

  Future<Keys> getKeyByTitle(String title) async {
    Database db = await _openDb();
    var result =
        await db.query(keys, where: "title = '${_cipher.encryptText(title)}'");
    

    if (result.length > 0) {
      return Keys.fromMapObject(_decrypt(result[0]));
    }

    return null;
  }

  Future<int> insertKey(Keys key) async {
    Database db = await _openDb();
    var result = await db.insert(
      keys,
      _encrypt(key.toMap()),
    );
    

    return result;
  }

  Future<int> updateKey(Keys key) async {
    Database db = await _openDb();
    var result = await db.update(
      keys,
      _encrypt(key.toMap()),
      where: "id = '${key.id}'",
    );
    

    return result;
  }

  Future<int> deleteKey(Keys key) async {
    Database db = await _openDb();
    var result = await db.delete(keys, where: "id = '${key.id}'");
    

    return result;
  }

  // CRUD Operations for Friends List
  Future<List<Map<String, dynamic>>> getFriendsMapList() async {
    Database db = await _openDb();
    var result = await db.query(friends, orderBy: 'id ASC');
    

    return result;
  }

  Future<List<Friend>> getFriendsList() async {
    var friendsMapList = await getFriendsMapList();

    List<Friend> friendsList = [];

    friendsMapList.forEach((element) {
      var currentMap = _decrypt(element);
      friendsList.add(Friend.fromMapObject(currentMap));
    });

    return friendsList;
  }

  Future<int> insertFriend(Friend friend) async {
    Database db = await _openDb();
    var result = await db.insert(
      friends,
      _encrypt(friend.toMap()),
    );
    

    return result;
  }

  Future<int> insertFriendMap(Map<String, dynamic> friendMap) async {
    Database db = await _openDb();
    var result = await db.insert(friends, _encrypt(friendMap));
    

    return result;
  }

  Future<int> updateFriend(Friend friend) async {
    Database db = await _openDb();
    var result = await db.update(
      friends,
      _encrypt(friend.toMap()),
      where: "id = '${friend.id}'",
    );
    

    return result;
  }

  Future<int> deleteFriend(Friend friend) async {
    Database db = await _openDb();
    var result = await db.delete(friends, where: "id = ${friend.id}");
    

    return result;
  }
}
