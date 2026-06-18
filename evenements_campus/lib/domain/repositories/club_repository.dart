import '../../domain/entities/club.dart';

abstract class ClubRepository {
  Future<List<Club>> getAllClubs();
  Future<List<Club>> getUserClubs(String userId);
  Future<void> joinClub(String clubId, String userId, String userName);
  Future<void> leaveClub(String clubId, String userId);
  Future<void> createClub(Club club);
  Future<void> updateClub(Club club);
  Future<void> deleteClub(String clubId);
  Future<void> addMember(String clubId, String userId, String userName);
  Future<void> removeMember(String clubId, String userId);
  Future<void> updateMemberRole(String clubId, String userId, String role);
  Future<bool> isUserMember(String clubId, String userId);
  Future<Club?> getClubById(String clubId);
}