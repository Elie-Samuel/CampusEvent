import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/club_repository.dart';
import '../../domain/entities/club.dart';
import '../datasources/local/app_database.dart';
import '../../core/constants/app_constants.dart';

class ClubRepositoryImpl implements ClubRepository {
  final AppDatabase appDatabase;

  ClubRepositoryImpl(this.appDatabase);

  Future<Database> get _db async => await appDatabase.database;

  @override
  Future<List<Club>> getAllClubs() async {
    final db = await _db;
    final results = await db.query(
      AppConstants.tableClubs,
      where: 'status = ?',
      whereArgs: ['active'],
    );
    return results.map((e) => Club.fromMap(e)).toList();
  }

  @override
  Future<List<Club>> getUserClubs(String userId) async {
    final db = await _db;
    final memberships = await db.query(
      AppConstants.tableClubMembers,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    final List<Club> clubs = [];
    for (var membership in memberships) {
      final clubId = membership['club_id'] as String;
      final clubResult = await db.query(
        AppConstants.tableClubs,
        where: 'id = ?',
        whereArgs: [clubId],
      );
      if (clubResult.isNotEmpty) {
        clubs.add(Club.fromMap(clubResult.first));
      }
    }
    return clubs;
  }

  @override
  Future<void> joinClub(String clubId, String userId, String userName) async {
    final db = await _db;
    
    final existing = await db.query(
      AppConstants.tableClubMembers,
      where: 'club_id = ? AND user_id = ?',
      whereArgs: [clubId, userId],
    );
    
    if (existing.isNotEmpty) return;
    
    await db.insert(
      AppConstants.tableClubMembers,
      {
        'club_id': clubId,
        'user_id': userId,
        'user_name': userName,
        'joined_at': DateTime.now().toIso8601String(),
        'role': 'member',
        'status': 'active',
      },
    );
    
    // Mettre à jour le compteur de membres
    final club = await db.query(
      AppConstants.tableClubs,
      where: 'id = ?',
      whereArgs: [clubId],
    );
    if (club.isNotEmpty) {
      final memberCount = club.first['member_count'] as int;
      await db.update(
        AppConstants.tableClubs,
        {'member_count': memberCount + 1},
        where: 'id = ?',
        whereArgs: [clubId],
      );
    }
  }

  @override
  Future<void> leaveClub(String clubId, String userId) async {
    final db = await _db;
    
    await db.delete(
      AppConstants.tableClubMembers,
      where: 'club_id = ? AND user_id = ?',
      whereArgs: [clubId, userId],
    );
    
    // Mettre à jour le compteur de membres
    final club = await db.query(
      AppConstants.tableClubs,
      where: 'id = ?',
      whereArgs: [clubId],
    );
    if (club.isNotEmpty) {
      final memberCount = club.first['member_count'] as int;
      await db.update(
        AppConstants.tableClubs,
        {'member_count': memberCount - 1},
        where: 'id = ?',
        whereArgs: [clubId],
      );
    }
  }

  @override
  Future<void> createClub(Club club) async {
    final db = await _db;
    await db.insert(AppConstants.tableClubs, club.toMap());
  }

  @override
  Future<void> updateClub(Club club) async {
    final db = await _db;
    await db.update(
      AppConstants.tableClubs,
      club.toMap(),
      where: 'id = ?',
      whereArgs: [club.id],
    );
  }

  @override
  Future<void> deleteClub(String clubId) async {
    final db = await _db;
    await db.delete(
      AppConstants.tableClubMembers,
      where: 'club_id = ?',
      whereArgs: [clubId],
    );
    await db.delete(
      AppConstants.tableClubs,
      where: 'id = ?',
      whereArgs: [clubId],
    );
  }

  @override
  Future<void> addMember(String clubId, String userId, String userName) async {
    await joinClub(clubId, userId, userName);
  }

  @override
  Future<void> removeMember(String clubId, String userId) async {
    await leaveClub(clubId, userId);
  }

  @override
  Future<void> updateMemberRole(String clubId, String userId, String role) async {
    final db = await _db;
    await db.update(
      AppConstants.tableClubMembers,
      {'role': role},
      where: 'club_id = ? AND user_id = ?',
      whereArgs: [clubId, userId],
    );
  }

  @override
  Future<bool> isUserMember(String clubId, String userId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableClubMembers,
      where: 'club_id = ? AND user_id = ?',
      whereArgs: [clubId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<Club?> getClubById(String clubId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableClubs,
      where: 'id = ?',
      whereArgs: [clubId],
    );
    if (result.isEmpty) return null;
    return Club.fromMap(result.first);
  }
}