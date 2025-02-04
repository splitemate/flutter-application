import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/utils/const.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Dio? _dio;
  BuildContext context;

  AuthService(this.context) {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.headers.containsKey("requiresToken")) {
          options.headers.remove("requiresToken");
          final userProvider = Provider.of<UserProvider>(context);
          var accessToken = userProvider.user.accessToken;
          if (accessToken.isNotEmpty) {
            if (JwtDecoder.isExpired(accessToken)) {
              accessToken = await refreshAccessToken();
              if (accessToken.isNotEmpty) {
                await saveUserData(accessToken: accessToken);
              }
            }
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.path != '/user/login' &&
            response.statusCode == 401) {
          return _refreshTokenAndRetry(response.requestOptions, handler);
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.requestOptions.path != '/user/login' &&
            error.response?.statusCode == 401) {
          return _refreshTokenAndRetry(error.requestOptions, handler);
        }
        return handler.next(error);
      },
    ));
  }

  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> loginWithGoogle() =>
      _googleSignIn.signIn();

  Future<Map<String, dynamic>?> externalLogin() async {
    try {
      final user = await loginWithGoogle();
      if (user == null) {
        throw UserNotFound();
      }
      String email = user.email;
      String name = user.displayName ?? '';
      String imageUrl = user.photoUrl ?? '';
      String userSource = 'google';

      final response = await _dio?.post('/user/external-auth', data: {
        'email': email,
        'name': name,
        'image_url': imageUrl,
        'user_source': userSource
      });

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        var data = response?.data;
        String accessToken = data['tokens']['access'];
        String refreshToken = data['tokens']['refresh'];

        var userData = data['user_data'];
        String userId = userData['id'];
        String userEmail = userData['email'];
        String userName = userData['name'];
        String imageUrl = userData['image_url'];
        Map<String, dynamic> balance = userData['balance'];

        await saveUserData(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userEmail: userEmail,
            userName: userName,
            userId: userId,
            imageUrl: imageUrl,
            balance: jsonEncode(balance));
        return {
          'id': userId,
          'email': userEmail,
          'name': userName,
          'balance': balance,
          'image_url': imageUrl,
          'tokens': {
            'access': accessToken,
            'refresh': refreshToken,
          }
        };
      } else {
        throw Exception('Unable to continue with Google');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  void _refreshTokenAndRetry(
    RequestOptions requestOptions,
    dynamic handler,
  ) async {
    try {
      var newAccessToken = await refreshAccessToken();
      if (newAccessToken.isNotEmpty) {
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final options = Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
        );
        await _dio?.request(requestOptions.path,
            options: options, data: requestOptions.data);
      }
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Unable to login');
      }
      final response = await _dio
          ?.post('/user/login', data: {'email': email, 'password': password});
      if (response?.statusCode == 200) {
        var data = response?.data;
        String accessToken = data['tokens']['access'];
        String refreshToken = data['tokens']['refresh'];

        var userData = data['user_data'];
        String userId = userData['id'];
        String userEmail = userData['email'];
        String userName = userData['name'];
        String imageUrl = userData['image_url'];
        Map<String, dynamic> balance = userData['balance'];

        await saveUserData(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userEmail: userEmail,
            userName: userName,
            userId: userId,
            imageUrl: imageUrl,
            balance: jsonEncode(balance));
        return {
          'id': userId,
          'email': userEmail,
          'name': userName,
          'balance': balance,
          'image_url': imageUrl,
          'tokens': {
            'access': accessToken,
            'refresh': refreshToken,
          }
        };
      } else {
        throw Exception('Unable to login');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw UnAuthorized('Unauthorized');
        } else if (e.response?.statusCode == 403) {
          var data = e.response?.data ?? {};
          var userData = data['user_data'] ?? {};

          throw UserIsNotVerified(
            message: 'User is not verified',
            id: userData['id'].toString(),
            email: userData['email'] ?? '',
            name: userData['name'] ?? 'unknown',
          );
        } else {
          throw Exception('An error occurred during the request.');
        }
      } else {
        throw Exception('An unexpected error occurred.');
      }
    }
  }

  Future<Map<String, dynamic>?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('Unable to login');
      }
      final response = await _dio?.post('/user/register',
          data: {'name': name, 'email': email, 'password': password});
      if (response?.statusCode == 201) {
        var data = response?.data;

        Map<String, dynamic> userData = data['user_data'];
        Map<String, dynamic> balance = userData['balance'];
        String userId = userData['id'];
        String userEmail = userData['email'];
        String userName = userData['name'];
        String imageUrl = userData['image_url'];

        await saveUserData(
            userEmail: userEmail,
            userName: userName,
            userId: userId,
            imageUrl: imageUrl,
            balance: jsonEncode(balance));
        return {
          'id': userId,
          'email': userEmail,
          'name': userName,
          'image_url': imageUrl,
          'balance': balance,
          'tokens': {'refresh': '', 'access': ''}
        };
      } else {
        throw Exception('Unable to sign up');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          throw UserAlreadyCreated('Conflict');
        } else {
          throw Exception('An error occurred during the request.');
        }
      } else {
        throw Exception('An unexpected error occurred.');
      }
    }
  }

  Future<bool> resendOtp(
      {required String userId,
      required String email,
      required String reason,
      required bool useId}) async {
    try {
      if ((useId && (userId.isEmpty || reason.isEmpty)) ||
          (!useId && (email.isEmpty || reason.isEmpty))) {
        throw Exception('Unable to resend OTP');
      }
      final Map<String, dynamic> data = useId
          ? {'user_id': userId, 'reason': reason}
          : {'email': email, 'reason': reason};
      final response = await _dio?.post('/otp/request-otp', data: data);
      if (response?.statusCode == 200) {
        return true;
      } else {
        throw Exception('Unable to send OTP');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 429) {
          throw OtpLimitExceed();
        }
      }
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(
      {required String userId,
      required String email,
      required String code,
      required String reason,
      required bool useId}) async {
    try {
      if ((useId && (userId.isEmpty || reason.isEmpty)) ||
          (!useId && (email.isEmpty || reason.isEmpty))) {
        throw Exception('Unable to verify OTP');
      }
      final Map<String, dynamic> data = useId
          ? {'user_id': userId, 'code': code, 'reason': reason}
          : {'email': email, 'code': code, 'reason': reason};
      final response = await _dio?.post('/otp/validate-otp', data: data);
      if (response?.statusCode == 200) {
        var data = response?.data;
        if (reason == "PR" &&
            data != null &&
            data is Map<String, dynamic> &&
            data.isNotEmpty) {
          var uid = data['uid'];
          var token = data['token'];
          return {"uid": uid, "token": token};
        } else if (reason == "EV" &&
            data != null &&
            data is Map<String, dynamic> &&
            data.isNotEmpty) {
          String id = data['id'];
          String name = data['name'];
          String email = data['email'];
          String imageUrl = data['image_url'];
          String accessToken = data['tokens']['access'];
          String refreshToken = data['tokens']['refresh'];
          Map<String, dynamic> balance = data['balance'];
          await saveUserData(
              userId: id,
              userName: name,
              userEmail: email,
              imageUrl: imageUrl,
              accessToken: accessToken,
              refreshToken: refreshToken,
              balance: jsonEncode(balance));
          return {
            'id': data['id'],
            'name': data['name'],
            'email': data['email'],
            'image_url': data['image_url'],
            'balance': balance,
            'tokens': {'access': accessToken, 'refresh': refreshToken},
          };
        } else {
          return {};
        }
      } else {
        throw Exception('Unable to sign up');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw InvalidOTP();
        }
      }
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<bool> forgotPw({
    required String email,
  }) async {
    try {
      if (email.isEmpty) {
        throw ApiRequestException('Unable to Send API request for reset pw');
      }
      final response =
          await _dio?.post('/user/forgot-password', data: {'email': email});
      if (response?.statusCode == 200) {
        return true;
      } else {
        throw ApiRequestException('Unable to Send API request for reset pw');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw UserNotFound();
        }
      }
      throw ApiRequestException('Unable to Send API request for reset pw');
    }
  }

  Future<bool> changePassword(
      {required String password,
      required String uid,
      required String token}) async {
    try {
      if (password.isEmpty || uid.isEmpty || token.isEmpty) {
        throw ApiRequestException('Unable to Send API request for reset pw');
      }
      final response = await _dio?.patch('/user/reset-password',
          data: {'password': password, 'uid': uid, 'token': token});
      if (response?.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw ApiRequestException('Unable to Send API request for reset pw');
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

  Future<String> refreshAccessToken() async {
    late String refreshToken;
    try {
      refreshToken = await getRefreshToken() ?? '';
      if (refreshToken.isEmpty) {
        return refreshToken;
      }
      final response = await _dio?.post(
        '/user/token/refresh',
        data: {'refresh': refreshToken},
      );
      if (response?.statusCode == 200 && response?.data != null) {
        var newAccessToke = response!.data['access'];
        await saveUserData(accessToken: newAccessToke);
        return newAccessToke;
      } else {
        return '';
      }
    } catch (e) {
      return '';
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
}
