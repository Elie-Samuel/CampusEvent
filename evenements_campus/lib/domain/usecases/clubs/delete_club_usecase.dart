import '../../repositories/club_repository.dart';

class DeleteClubUseCase {
  final ClubRepository repository;

  DeleteClubUseCase(this.repository);

  Future<void> call(String clubId) async {
    if (clubId.isEmpty) throw Exception('ID club requis');
    
    await repository.deleteClub(clubId);
  }
}