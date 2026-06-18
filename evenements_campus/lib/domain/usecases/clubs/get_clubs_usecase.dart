import '../../repositories/club_repository.dart';
import '../../entities/club.dart';

class GetAllClubsUseCase {
  final ClubRepository repository;
  GetAllClubsUseCase(this.repository);
  Future<List<Club>> call() => repository.getAllClubs();
}

class GetUserClubsUseCase {
  final ClubRepository repository;
  GetUserClubsUseCase(this.repository);
  Future<List<Club>> call(String userId) => repository.getUserClubs(userId);
}

class GetClubByIdUseCase {
  final ClubRepository repository;
  GetClubByIdUseCase(this.repository);
  Future<Club?> call(String id) => repository.getClubById(id);
}