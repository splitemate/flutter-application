import 'dart:async';
import 'package:splitemate/service/auth_service.dart';

class AuthRepository {
  AuthRepository({required this.service});

  final AuthService service;

  Future signInWithEmail({required String email, required String password}) {
    return service.login(email: email, password: password);
  }

  Future signUpWithEmail(
      {required String name, required String email, required String password}) {
    return service.signup(name: name, email: email, password: password);
  }

  Future validateOtp(
      {required String userId,
      required String email,
      required String code,
      required String reason,
      required bool useId}) {
    return service.verifyOtp(
        userId: userId, email: email, code: code, reason: reason, useId: useId);
  }

  Future resendOtp(
      {required String userId,
      required String email,
      required String reason,
      required bool useId}) {
    return service.resendOtp(
        userId: userId, email: email, reason: reason, useId: useId);
  }

  Future forgotPw({required String email}) {
    return service.forgotPw(email: email);
  }

  Future changePassword(
      {required String password, required String uid, required String token}) {
    return service.changePassword(password: password, uid: uid, token: token);
  }

  Future externalAuth() {
    return service.externalLogin();
  }
}
