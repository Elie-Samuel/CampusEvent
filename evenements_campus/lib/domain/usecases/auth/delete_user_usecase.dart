// lib/domain/usecases/auth/delete_user_usecase.dart

import '../../repositories/auth_repository.dart';

class DeleteUserUseCase {
  final AuthRepository repository;

  DeleteUserUseCase(this.repository);

  Future<bool> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}