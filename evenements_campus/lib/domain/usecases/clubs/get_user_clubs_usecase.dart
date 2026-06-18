import '../../entities/club.dart';
import '../../repositories/club_repository.dart';

class GetUserClubsUseCase {
  final ClubRepository repository;

  GetUserClubsUseCase(this.repository);

  Future<List<Club>> call(String userId) async {
    if (userId.isEmpty) throw Exception("ID de l'utilisateur requis");
    return repository.getUserClubs(userId);
  }
}
