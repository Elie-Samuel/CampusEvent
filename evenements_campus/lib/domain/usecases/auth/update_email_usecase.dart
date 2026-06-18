// lib/domain/usecases/auth/update_email_usecase.dart

import '../../repositories/auth_repository.dart';

class UpdateEmailUseCase {
  final AuthRepository repository;

  UpdateEmailUseCase(this.repository);

  Future<bool> call(String userId, String newEmail) async {
    return await repository.updateEmail(userId, newEmail);
  }
}