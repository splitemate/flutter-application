import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitemate/utils/const.dart';
import 'package:splitemate/utils/firebase_config.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:splitemate/models/current_user.dart';

class ApiService {
  static ApiService? _instance;
  static Dio? _dio;
  static bool _isRefreshing = false;
  static final List<Future Function()> _pendingRequests = [];

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  ApiService._internal();

  Dio get dio {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      _setupInterceptors();
    }
    return _dio!;
  }

  void _setupInterceptors() {
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check if this request requires authentication
        if (options.headers.containsKey('requiresToken')) {
          options.headers.remove('requiresToken');
          final accessToken = await getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          return _handleTokenRefresh(error, handler);
        }
        return handler.next(error);
      },
    ));
  }

  // HTTP Methods
  Future<Response> get(String path) async {
    return await dio.get(path);
  }

  Future<Response> post(String path, [dynamic data]) async {
    return await dio.post(path, data: data);
  }

  Future<Response> patch(String path, [dynamic data]) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> put(String path, [dynamic data]) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }

  Future<void> _handleTokenRefresh(
      DioException error, ErrorInterceptorHandler handler) async {
    if (_isRefreshing) {
      // If already refreshing, queue this request
      final completer = Completer<Response>();
      _pendingRequests.add(() async {
        try {
          final response = await _dio!.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          completer.complete(response);
        } catch (e) {
          completer.completeError(e);
        }
      });
      return completer.future.then((response) => handler.resolve(response));
    }

    _isRefreshing = true;
    ;

    try {
      final newToken = await _refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        // Update the failed request with new token
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry the original request using the same Dio instance
        final response = await _dio!.request(
          error.requestOptions.path,
          options: Options(
            method: error.requestOptions.method,
            headers: error.requestOptions.headers,
          ),
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters,
        );

        // Process pending requests
        for (final pendingRequest in _pendingRequests) {
          await pendingRequest();
        }
        _pendingRequests.clear();

        _isRefreshing = false;
        return handler.resolve(response);
      } else {
        _isRefreshing = false;
        return handler.next(error);
      }
    } catch (e) {
      print('Exception during token refresh: $e');
      _isRefreshing = false;
      return handler.next(error);
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Create a separate Dio instance for refresh to avoid interceptor interference
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await refreshDio.post(
        '/user/token/refresh',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access'];
        await prefs.setString('access_token', newAccessToken);
        
        // Update the UserProvider with the new token
        await _updateUserProviderToken(newAccessToken);
        
        return newAccessToken;
      }
      return null;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }

  Future<void> _updateUserProviderToken(String newAccessToken) async {
    try {
      // Get the current user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      final userImageUrl = prefs.getString('user_image_url');
      final refreshToken = prefs.getString('refresh_token');
      final inviteToken = prefs.getString('invite_token');
      
      if (userId != null && userName != null && userEmail != null) {
        // Create a new CurrentUser with the updated token
        final updatedUser = CurrentUser(
          id: userId,
          name: userName,
          email: userEmail,
          imageUrl: userImageUrl ?? '',
          accessToken: newAccessToken,
          refreshToken: refreshToken ?? '',
          totalOwed: 0.0, // These will be updated when user data is fetched
          totalDue: 0.0,
          netBalance: 0.0,
          inviteToken: inviteToken ?? '',
        );
        
        // Note: We can't directly access UserProvider here since this is a service
        // The UserProvider will be updated when the next API call is made
        // or when the user navigates to a screen that can access the context
        print('Token refreshed and saved. New token: $newAccessToken');
      }
    } catch (e) {
      print('Error updating UserProvider token: $e');
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null && accessToken.isNotEmpty) {
      if (JwtDecoder.isExpired(accessToken)) {
        return await _refreshAccessToken();
      }
      return accessToken;
    }
    return null;
  }
}
