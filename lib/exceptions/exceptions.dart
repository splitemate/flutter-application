class ApiConnectionTimeout implements Exception {
  @override
  String toString() => 'Api Connection Timeout';
}

class ApiRequestException implements Exception {
  final String message;

  ApiRequestException(this.message);

  @override
  String toString() => 'ApiRequestException: $message';
}

class ApiBadRequestException implements Exception {
  final String message;

  ApiBadRequestException(this.message);

  @override
  String toString() => 'ApiRequestException: $message';
}

class UserIsNotVerified implements Exception {
  final String message;
  final String email;
  final String name;
  final String id;

  UserIsNotVerified({
    required this.message,
    required this.email,
    required this.name,
    required this.id,
  });

  @override
  String toString() =>
      'User is not verified\nEmail: $email\nName: $name\nID: $id';

  Map<String, String> getDetails() => {
        'email': email,
        'name': name,
        'id': id,
      };
}

class UserAlreadyCreated implements Exception {
  final String message;

  UserAlreadyCreated(this.message);

  @override
  String toString() => 'User is already created: $message';
}

class UserNotFound implements Exception {
  @override
  String toString() => 'User is not found';
}

class UnAuthorized implements Exception {
  final String message;

  UnAuthorized(this.message);

  @override
  String toString() => 'User is not authorized: $message';
}

class InvalidOTP implements Exception {
  @override
  String toString() => 'Invalid OTP';
}

class OtpLimitExceed implements Exception {
  @override
  String toString() => 'OTP Limit Exceed';
}
