import '../../repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel?> call() async {
    return await repository.getCurrentUser();
  }
}