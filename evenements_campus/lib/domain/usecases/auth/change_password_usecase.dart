// lib/domain/usecases/auth/change_password_usecase.dart

import '../../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<bool> call(String userId, String newPassword) async {
    return await repository.changePassword(userId, newPassword);
  }
}