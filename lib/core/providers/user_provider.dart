import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String? _userId;
  String? _userName;
  String? _userEmail;

  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  bool get isLoggedIn => _userId != null;

  void setUser(String id, String name, String email) {
    final isUnchanged =
        _userId == id && _userName == name && _userEmail == email;
    if (isUnchanged) {
      return;
    }
    _userId = id;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    clearUser();
  }

  void clearUser() {
    final isAlreadyClear = _userId == null && _userName == null && _userEmail == null;
    if (isAlreadyClear) {
      return;
    }
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
