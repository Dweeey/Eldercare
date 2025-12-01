import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _userName;
  String? _userEmail;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _userId != null;

  void setUser(int id, String name, String email) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }

  void updateName(String name) {
    _userName = name;
    notifyListeners();
  }
}