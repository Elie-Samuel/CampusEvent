import '../../repositories/club_repository.dart';
import '../../entities/club.dart';

class UpdateClubUseCase {
  final ClubRepository repository;

  UpdateClubUseCase(this.repository);

  Future<void> call(Club club) async {
    if (club.id.isEmpty) throw Exception('ID club requis');
    if (club.name.isEmpty) throw Exception('Le nom du club est requis');
    
    await repository.updateClub(club);
  }
}