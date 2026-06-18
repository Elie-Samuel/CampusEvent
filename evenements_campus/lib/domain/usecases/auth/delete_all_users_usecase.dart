// lib/domain/usecases/auth/delete_all_users_usecase.dart

import '../../repositories/auth_repository.dart';

class DeleteAllUsersUseCase {
  final AuthRepository repository;

  DeleteAllUsersUseCase(this.repository);

  Future<bool> call() async {
    return await repository.deleteAllUsers();
  }
}