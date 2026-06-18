import 'package:flutter/material.dart';
import '../../domain/entities/club.dart';
import '../../domain/usecases/clubs/get_clubs_usecase.dart';
import '../../domain/usecases/clubs/join_club_usecase.dart';
import '../../domain/usecases/clubs/create_club_usecase.dart';
import '../../domain/usecases/clubs/update_club_usecase.dart';
import '../../domain/usecases/clubs/delete_club_usecase.dart';
import '../../domain/usecases/clubs/manage_members_usecase.dart';

class ClubViewModel extends ChangeNotifier {
  final GetAllClubsUseCase getAllClubsUseCase;
  final GetUserClubsUseCase getUserClubsUseCase;
  final JoinClubUseCase joinClubUseCase;
  final LeaveClubUseCase leaveClubUseCase;
  final CreateClubUseCase createClubUseCase;
  final UpdateClubUseCase updateClubUseCase;
  final DeleteClubUseCase deleteClubUseCase;
  final ManageMembersUseCase manageMembersUseCase;

  List<Club> _clubs = [];
  List<Club> _userClubs = [];
  bool _isLoading = false;
  String? _errorMessage;

  ClubViewModel({
    required this.getAllClubsUseCase,
    required this.getUserClubsUseCase,
    required this.joinClubUseCase,
    required this.leaveClubUseCase,
    required this.createClubUseCase,
    required this.updateClubUseCase,
    required this.deleteClubUseCase,
    required this.manageMembersUseCase,
  });

  List<Club> get clubs => _clubs;
  List<Club> get userClubs => _userClubs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadClubs() async {
    _setLoading(true);
    try {
      _clubs = await getAllClubsUseCase();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }


  // Ajoutez ces méthodes à la fin de la classe ClubViewModel

// Gestion des clubs (pour l'admin)
List<Club> _allClubs = [];

List<Club> get allClubs => _allClubs;

Future<void> getAllClubs() async {
  _setLoading(true);
  try {
    await loadClubs();
    _allClubs = _clubs;
    _errorMessage = null;
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _setLoading(false);
  }
}

  Future<void> loadUserClubs(String userId) async {
    if (userId.isEmpty) return;
    try {
      _userClubs = await getUserClubsUseCase(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> joinClub(String clubId, String userId, String userName) async {
    try {
      await joinClubUseCase(clubId, userId, userName);
      await loadClubs();
      await loadUserClubs(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> leaveClub(String clubId, String userId) async {
    try {
      await leaveClubUseCase(clubId, userId);
      await loadClubs();
      await loadUserClubs(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> createClub(Club club) async {
    _setLoading(true);
    try {
      await createClubUseCase(club);
      await loadClubs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateClub(Club club) async {
    _setLoading(true);
    try {
      await updateClubUseCase(club);
      await loadClubs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteClub(String clubId) async {
    _setLoading(true);
    try {
      await deleteClubUseCase(clubId);
      await loadClubs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool isJoined(String clubId) => _userClubs.any((c) => c.id == clubId);
  
  Club? getClubById(String id) {
    try {
      return _clubs.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}