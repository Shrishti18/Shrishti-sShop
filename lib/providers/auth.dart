import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:myshop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String user;
  DateTime _expiryDate;
  Timer authTimer;
  //Auth(this._token, this._expiryDate, this._userId);

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return user;
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDJesAea1OtNzE2nWIM8rD0JXF4S-3kIqw');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responsedata = json.decode(response.body);
      if (responsedata['error'] != null) {
        throw HttpException(responsedata['error']['message']);
      }
      _token = responsedata['idToken'];
      user = responsedata['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responsedata['expiresIn'])));
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': user,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    //print();
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDJesAea1OtNzE2nWIM8rD0JXF4S-3kIqw');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responsedata = json.decode(response.body);
      if (responsedata['error'] != null) {
        throw HttpException(responsedata['error']['message']);
      }
      _token = responsedata['idToken'];
      user = responsedata['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responsedata['expiresIn'])));
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': user,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
    //print();
  }

  Future<bool> tryautologin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extracted =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expire = DateTime.parse(extracted['expiryDate']);
    if (expire.isBefore(DateTime.now())) {
      return false;
    }
    _token = extracted['token'];
    user = extracted['userId'];
    _expiryDate = expire;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    user = null;
    _expiryDate = null;
    if (authTimer != null) {
      authTimer.cancel();
    }
    authTimer = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogOut() {
    if (authTimer != null) {
      authTimer.cancel();
    }

    final timetoexpire = _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timetoexpire), logOut);
  }
}
