// lib/domain/usecases/auth/register_usecase.dart

import '../../repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  // ✅ AJOUT du paramètre role avec valeur par défaut 'student'
  Future<UserModel> call(String email, String password, String fullName, {String role = 'student'}) async {
    return await repository.register(email, password, fullName, role: role);
  }
}