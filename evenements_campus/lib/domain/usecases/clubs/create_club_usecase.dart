import '../../repositories/club_repository.dart';
import '../../entities/club.dart';

class CreateClubUseCase {
  final ClubRepository repository;

  CreateClubUseCase(this.repository);

  Future<void> call(Club club) async {
    if (club.name.isEmpty) throw Exception('Le nom du club est requis');
    if (club.description.isEmpty) throw Exception('La description est requise');
    
    await repository.createClub(club);
  }
}