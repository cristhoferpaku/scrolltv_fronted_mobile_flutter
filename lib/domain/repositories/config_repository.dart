// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ConfigRepository {
  
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();
  Future<void> saveTryIntent();
  Future<void> clearIntents();
  Future<int> getIntents();
  Future<DateTime?> getDateToLogin();
}

class ConfigRepositoryImpl extends ConfigRepository {

  final keyLanguage = 'SP_KEY_LANGUAGE';
  final ketIntents = 'SP_KEY_INTENTS';
  final timeToLock = 'SP_KEY_TIME_LOCK';

  static final ConfigRepositoryImpl _singleton = ConfigRepositoryImpl._internal();

  factory ConfigRepositoryImpl() {
    return _singleton;
  }

  ConfigRepositoryImpl._internal();


  @override
  Future<void> saveLanguage(String language) async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, language);
  }

  @override
  Future<String> getLanguage() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    var userLogged = prefs.getString(keyLanguage);
    return userLogged ?? 'ES';
  }
  
  @override
  Future<void> clearIntents() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(timeToLock, '');
    await prefs.setInt(ketIntents, 0);
  }
  
  @override
  Future<int> getIntents() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ketIntents) ?? 0;
  }
  
  @override
  Future<void> saveTryIntent() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    var getIntents = prefs.getInt(ketIntents) ?? 0;
    if(getIntents >= 2){
      var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      await prefs.setString(timeToLock, dateFormat.format(DateTime.now().add(const Duration(minutes: 5))));
    }
    await prefs.setInt(ketIntents, getIntents+1);
  }
  
  @override
  Future<DateTime?> getDateToLogin() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    var dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    if (prefs.getString(timeToLock) == null || prefs.getString(timeToLock) == ''){
      return null;
    } else {
      return dateFormat.parse(prefs.getString(timeToLock) ?? dateFormat.format(DateTime.now()));
    }
    
  }

}