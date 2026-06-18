// lib/domain/usecases/auth/get_all_users_usecase.dart

import '../../repositories/auth_repository.dart';
import '../../../data/models/user_model.dart'; // ✅ AJOUT DE L'IMPORT

class GetAllUsersUseCase {
  final AuthRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<List<UserModel>> call() async {
    return await repository.getAllUsers();
  }
}