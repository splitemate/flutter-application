import 'package:dio/dio.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/service/api_service.dart';

class FriendResult {
  final User user;
  final bool isAlreadyFriend;

  FriendResult({required this.user, required this.isAlreadyFriend});
}

class FriendService {
  static final FriendService _instance = FriendService._internal();

  factory FriendService() => _instance;

  FriendService._internal();

  final ApiService _apiService = ApiService();

  Future<FriendResult> addFriend(String token) async {
    try {
      final response = await _apiService.dio.post(
        '/user/add-friend/$token',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'requiresToken': true,
          },
        ),
      );

      if (response.statusCode == 200) {
        return FriendResult(
          user: User.fromJson(response.data),
          isAlreadyFriend: false,
        );
      } else {
        throw Exception('Failed to add friend: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found with this QR code');
      } else if (e.response?.statusCode == 409) {
        // If user is already a friend, still return the user details
        if (e.response?.data != null) {
          return FriendResult(
            user: User.fromJson(e.response!.data),
            isAlreadyFriend: true,
          );
        } else {
          throw Exception('User is already your friend');
        }
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid QR code');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
