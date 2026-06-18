import '../../repositories/club_repository.dart';

class ManageMembersUseCase {
  final ClubRepository repository;

  ManageMembersUseCase(this.repository);

  Future<void> addMember(String clubId, String userId, String userName) async {
    if (clubId.isEmpty) throw Exception('ID club requis');
    if (userId.isEmpty) throw Exception('ID utilisateur requis');
    
    await repository.addMember(clubId, userId, userName);
  }

  Future<void> removeMember(String clubId, String userId) async {
    if (clubId.isEmpty) throw Exception('ID club requis');
    if (userId.isEmpty) throw Exception('ID utilisateur requis');
    
    await repository.removeMember(clubId, userId);
  }

  Future<void> updateMemberRole(String clubId, String userId, String role) async {
    if (clubId.isEmpty) throw Exception('ID club requis');
    if (userId.isEmpty) throw Exception('ID utilisateur requis');
    
    await repository.updateMemberRole(clubId, userId, role);
  }
}