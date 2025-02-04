import 'package:splitemate/models/user.dart';

abstract class IUserService {
  Future<List<User>> fetch(List<String?> ids);
}

class UserService extends IUserService {
  User _generateMockUser(String id) {
    return User.fromJson({
      'id': id,
      'name': 'User $id',
      'email': 'user$id@example.com',
      'image_url': 'photo$id.jpg',
    });
  }

  @override
  Future<List<User>> fetch(List<String?> ids) {
    final users = ids
        .where((id) => id != null)
        .map((id) => _generateMockUser(id!))
        .toList();
    return Future.value(users);
  }
}
