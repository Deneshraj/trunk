import 'package:flutter/foundation.dart';
import 'package:trunk/db/db.dart';

class DatabaseHelperInit with ChangeNotifier {
  DatabaseHelper _databaseHelper;

  void setDatabaseHelper(DatabaseHelper databaseHelper) {
    _databaseHelper = databaseHelper;
    notifyListeners();
  }

  DatabaseHelper get databaseHelper {
    return _databaseHelper;
  }
}