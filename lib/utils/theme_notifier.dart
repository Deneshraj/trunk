import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  String key = "theme";
  bool _light;
  SharedPreferences _prefs;
  
  bool get light => _light;

  ThemeNotifier() {
    _light = true;
    _loadSharedPrefs();
  }

  toggleTheme() {
    _light = !_light;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if(_prefs == null) _prefs = await SharedPreferences.getInstance();
  }

  _loadSharedPrefs() async {
    await _initPrefs();
    if(_prefs.containsKey(key)) _light = _prefs.getBool(key);
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs.setBool(key, _light);
  }
}