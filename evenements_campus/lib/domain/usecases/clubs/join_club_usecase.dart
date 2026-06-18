import '../../repositories/club_repository.dart';

class JoinClubUseCase {
  final ClubRepository repository;
  JoinClubUseCase(this.repository);
  Future<void> call(String clubId, String userId, String userName) async {
    final isMember = await repository.isUserMember(clubId, userId);
    if (isMember) throw Exception('Vous êtes déjà membre de ce club');
    await repository.joinClub(clubId, userId, userName);
  }
}

class LeaveClubUseCase {
  final ClubRepository repository;
  LeaveClubUseCase(this.repository);
  Future<void> call(String clubId, String userId) async {
    await repository.leaveClub(clubId, userId);
  }
}