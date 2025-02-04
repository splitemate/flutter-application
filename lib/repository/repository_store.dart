import 'package:flutter/cupertino.dart';
import 'package:splitemate/repository/auth_repository.dart';
import 'package:splitemate/service/auth_service.dart';

class RepositoryStore {
  final BuildContext context;
  RepositoryStore({required this.context});
  late final AuthRepository authRepository = AuthRepository(service: AuthService(context));
}
