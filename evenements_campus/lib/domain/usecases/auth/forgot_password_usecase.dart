import '../../repositories/auth_repository.dart';

class SendResetCodeUseCase {
  final AuthRepository repository;

  SendResetCodeUseCase(this.repository);

  Future<Map<String, dynamic>> call(String email) async {
    if (email.isEmpty) {
      throw Exception('Email requis');
    }
    if (!email.contains('@')) {
      throw Exception('Email invalide');
    }
    return await repository.sendResetCode(email);
  }
}

class SendResetCodeWithRoleUseCase {
  final AuthRepository repository;

  SendResetCodeWithRoleUseCase(this.repository);

  Future<Map<String, dynamic>> call(String email, String role) async {
    if (email.isEmpty) {
      throw Exception('Email requis');
    }
    if (!email.contains('@')) {
      throw Exception('Email invalide');
    }
    if (role.isEmpty) {
      throw Exception('Rôle requis');
    }
    return await repository.sendResetCodeWithRole(email, role);
  }
}

class VerifyResetCodeUseCase {
  final AuthRepository repository;

  VerifyResetCodeUseCase(this.repository);

  Future<bool> call(String email, String code) async {
    if (email.isEmpty) throw Exception('Email requis');
    if (code.isEmpty) throw Exception('Code requis');
    if (code.length != 6) throw Exception('Code invalide (6 chiffres)');
    
    return await repository.verifyResetCode(email, code);
  }
}

class ResetPasswordWithCodeUseCase {
  final AuthRepository repository;

  ResetPasswordWithCodeUseCase(this.repository);

  Future<bool> call(String email, String code, String newPassword) async {
    if (email.isEmpty) throw Exception('Email requis');
    if (code.isEmpty) throw Exception('Code requis');
    if (newPassword.isEmpty) throw Exception('Nouveau mot de passe requis');
    if (newPassword.length < 6) throw Exception('Mot de passe trop court (min 6 caractères)');
    
    return await repository.resetPasswordWithCode(email, code, newPassword);
  }
}