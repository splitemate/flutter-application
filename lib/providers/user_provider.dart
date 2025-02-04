import 'package:flutter/material.dart';
import 'package:splitemate/models/current_user.dart';

class UserProvider extends ChangeNotifier {
  CurrentUser _user = CurrentUser.empty();

  CurrentUser get user => _user;

  void setUser(CurrentUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = CurrentUser.empty();
    notifyListeners();
  }
}
