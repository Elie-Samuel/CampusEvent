import '../../repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel?> call(String email, String password) async {
    if (email.isEmpty) {
      throw Exception('Email requis');
    }
    if (password.isEmpty) {
      throw Exception('Mot de passe requis');
    }
    return await repository.login(email, password);
  }
}