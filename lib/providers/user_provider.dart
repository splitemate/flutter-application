import 'package:flutter/material.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void updateInviteToken(String newToken) {
    _user = CurrentUser(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      imageUrl: _user.imageUrl,
      accessToken: _user.accessToken,
      refreshToken: _user.refreshToken,
      totalOwed: _user.totalOwed,
      totalDue: _user.totalDue,
      netBalance: _user.netBalance,
      inviteToken: newToken,
    );
    notifyListeners();
  }

  Future<void> saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _user.id);
      await prefs.setString('user_name', _user.name);
      await prefs.setString('user_email', _user.email);
      await prefs.setString('user_image_url', _user.imageUrl);
      await prefs.setString('access_token', _user.accessToken);
      await prefs.setString('refresh_token', _user.refreshToken);
      await prefs.setString('invite_token', _user.inviteToken);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }
}
