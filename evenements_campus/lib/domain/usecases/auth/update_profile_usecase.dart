import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserModel?> call({
    required String userId,
    required String fullName,
    required String role,
    String? profileImage,
  }) async {
    if (userId.isEmpty) throw Exception("ID de l'utilisateur requis");
    if (fullName.isEmpty) throw Exception("Nom complet requis");
    return repository.updateProfile(userId, fullName, role, profileImage);
  }
}
