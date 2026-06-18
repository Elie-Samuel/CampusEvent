import '../../repositories/auth_repository.dart';

class DeleteProfileImageUseCase {
  final AuthRepository repository;

  DeleteProfileImageUseCase(this.repository);

  Future<void> call(String userId) async {
    await repository.deleteProfileImage(userId);
  }
}