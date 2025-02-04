import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:splitemate/utils/const.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitAuthService {
  static Dio? _dio;

  InitAuthService() {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: '$baseUrl/user',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<String?> getValidTokenOnLogin() async {
    var accessToken = await getAccessToken();
    if (accessToken != null) {
      bool hasExpired = JwtDecoder.isExpired(accessToken);
      if (hasExpired) {
        var newToken = await refreshAccessToken();
        if (newToken != null) {
          return newToken;
        } else {
          return '';
        }
      } else {
        return accessToken;
      }
    } else {
      return '';
    }
  }

  Future<String?> getAccessToken() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getRefreshToken() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }
      final response = await _dio?.post(
        '/token/refresh',
        data: {'refresh': refreshToken},
      );
      if (response?.statusCode == 200 && response?.data != null) {
        var newAccessToke = response!.data['access'];
        await saveUserData(accessToken: newAccessToke);
        return newAccessToke;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserData(
      {String? accessToken,
      String? refreshToken,
      String? userName,
      String? userEmail,
      String? userId,
      String? imageUrl,
      String? balance}) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> dataToSave = {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_name': userName,
      'user_email': userEmail,
      'user_id': userId,
      'balance': balance,
      'image_url': imageUrl,
    };

    final batch = <Future<void>>[];

    dataToSave.forEach((key, value) {
      if (value != null) {
        if (value is int) {
          batch.add(prefs.setInt(key, value));
        } else if (value is String) {
          batch.add(prefs.setString(key, value));
        }
      }
    });
    await Future.wait(batch);
  }

  Future<Map<String, dynamic>> getUserDetails(String givenAccessToken) async {
    late String? userId;
    late String? userName;
    late String? userEmail;
    late String? imageUrl;
    late String? accessToken;
    late String? refreshToken;
    late Map<String, dynamic>? balance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await _dio?.get(
        '/profile',
        options: Options(
          headers: <String, dynamic>{
            'Authorization': 'Bearer $givenAccessToken',
          },
        ),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        userName = response?.data['name'];
        userEmail = response?.data['email'];
        userId = response?.data['id'];
        balance = response?.data['balance'];
        imageUrl = response?.data['image_url'];
        await saveUserData(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            balance: jsonEncode(balance),
            imageUrl: imageUrl);
      } else {
        String bal = prefs.getString('balance') ?? '';
        userId = prefs.getString('user_id');
        userName = prefs.getString('user_name');
        userEmail = prefs.getString('user_email');
        balance = jsonDecode(bal);
        imageUrl = prefs.getString('image_url');
      }
    } on DioException catch (e) {
      throw ApiConnectionTimeout();
    } catch (e) {
      throw ApiRequestException('Unable to get User Profile');
    }

    accessToken = prefs.getString('access_token');
    refreshToken = prefs.getString('refresh_token');

    return {
      'id': userId,
      'name': userName,
      'email': userEmail,
      'image_url': imageUrl,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'balance': balance
    };
  }

  CurrentUser getCurrentUser(Map<String, dynamic> userDetailsMap) {
    CurrentUser user = CurrentUser.fromMap(userDetailsMap);
    return user;
  }
}
