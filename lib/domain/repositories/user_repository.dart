// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserRepository {
  Future<void> saveUser(String userEmail, String userName, String userAvatar);
  Future<void> clearUser();
  Future<bool> isUserLogged();
  Future<String> getUserEmail();
  Future<String> getUserName();
  Future<void> logoutUser();
  Future<void> saveToken(String token);
  Future<void> saveTokenRefresh(String refreshToken);
  Future<String> getToken();
  Future<String> getTokenRefresh();
  Future<String> getUserId();
  Future<void> saveUserId(String userId);
}

class UserRepositoryImpl extends UserRepository {
  final keyUserEmail = 'SP_KEY_USER_EMAIL';
  final keyUserName = 'SP_KEY_USER_NAME';
  final keyUserIsLogged = 'SP_KEY_USER_IS_LOGGED';
  final keyUserToken = 'SP_KEY_TOKEN_USER';
  final keyUserTokenRefresh = 'SP_KEY_TOKEN_REFRESH_USER';
  final keyUserId = 'SP_KEY_USER_ID';


  static final UserRepositoryImpl _singleton = UserRepositoryImpl._internal();

  factory UserRepositoryImpl() {
    return _singleton;
  }

  UserRepositoryImpl._internal();

  @override
  Future<void> clearUser() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> saveUser(
      String userEmail, String userName, String userAvatar) async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyUserIsLogged, true);
    await prefs.setString(keyUserEmail, userEmail);
    await prefs.setString(keyUserName, userName);
  }




  @override
  Future<void> saveToken(String token) async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserToken, token);
  }

  @override
  Future<String> getToken() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserToken) ?? '';
  }

  @override
  Future<void> saveTokenRefresh(String refreshToken) async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserTokenRefresh, refreshToken);
  }

  @override
  Future<String> getTokenRefresh() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserTokenRefresh) ?? '';
  }

  @override
  Future<String> getUserEmail() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail) ?? '';
  }

  @override
  Future<String> getUserName() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? '';
  }


  @override
  Future<bool> isUserLogged() async {
    WidgetsFlutterBinding.ensureInitialized();
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyUserIsLogged) ?? false;
  }

 
  @override
  Future<void> logoutUser() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  @override
  Future<String> getUserId() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? '';
  }
  
  @override
  Future<void> saveUserId(String userId) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserId, userId);
  }


}
