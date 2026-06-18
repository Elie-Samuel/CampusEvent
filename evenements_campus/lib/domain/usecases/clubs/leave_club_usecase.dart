import '../../repositories/club_repository.dart';

class LeaveClubUseCase {
  final ClubRepository repository;

  LeaveClubUseCase(this.repository);

  Future<void> call(String clubId, String userId) async {
    if (clubId.isEmpty) throw Exception("ID du club requis");
    if (userId.isEmpty) throw Exception("ID de l'utilisateur requis");
    return repository.leaveClub(clubId, userId);
  }
}
