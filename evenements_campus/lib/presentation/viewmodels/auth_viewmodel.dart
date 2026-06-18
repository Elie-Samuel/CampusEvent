import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/change_password_usecase.dart'; // AJOUT
import '../../domain/usecases/auth/update_email_usecase.dart'; // AJOUT
import '../../domain/usecases/auth/get_all_users_usecase.dart';
import '../../domain/usecases/auth/delete_user_usecase.dart';
import '../../domain/usecases/auth/delete_all_users_usecase.dart';
import '../../data/models/user_model.dart';
import 'notification_viewmodel.dart';
import '../../core/constants/app_constants.dart';

final getIt = GetIt.instance;

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendResetCodeUseCase sendResetCodeUseCase;
  final SendResetCodeWithRoleUseCase sendResetCodeWithRoleUseCase;
  final VerifyResetCodeUseCase verifyResetCodeUseCase;
  final ResetPasswordWithCodeUseCase resetPasswordWithCodeUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateEmailUseCase updateEmailUseCase;
  final ChangePasswordUseCase changePasswordUseCase; // AJOUT
  final GetAllUsersUseCase getAllUsersUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final DeleteAllUsersUseCase deleteAllUsersUseCase;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastGeneratedCode;
  List<UserModel> _allUsers = [];

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendResetCodeUseCase,
    required this.sendResetCodeWithRoleUseCase,
    required this.verifyResetCodeUseCase,
    required this.resetPasswordWithCodeUseCase,
    required this.updateProfileUseCase,
    required this.updateEmailUseCase,
    required this.changePasswordUseCase, // AJOUT
    required this.getAllUsersUseCase,
    required this.deleteUserUseCase,
    required this.deleteAllUsersUseCase,
  });

  // ─── Getters ──────────────────────────────────────────────────────

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  String? get lastGeneratedCode => _lastGeneratedCode;
  List<UserModel> get allUsers => _allUsers;
  
  // Helpers pour les rôles
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isOrganizer => _currentUser?.role == 'organizer';
  bool get isClubPresident => _currentUser?.role == 'club_president';
  bool get isStudent => _currentUser?.role == 'student';
  
  String get roleLabel {
    switch (_currentUser?.role) {
      case 'admin': return 'Administrateur';
      case 'organizer': return 'Organisateur';
      case 'club_president': return 'Chef de club';
      default: return 'Étudiant';
    }
  }
  
  // ─── Permissions ──────────────────────────────────────────────────

  bool canCreateEvent() {
    return isAdmin || isOrganizer || isClubPresident;
  }
  
  bool canEditEvent(String organizerId) {
    if (isAdmin) return true;
    if (isOrganizer && _currentUser?.id == organizerId) return true;
    if (isClubPresident && _currentUser?.id == organizerId) return true;
    return false;
  }
  
  bool canDeleteEvent(String organizerId) {
    if (isAdmin) return true;
    if (isOrganizer && _currentUser?.id == organizerId) return true;
    if (isClubPresident && _currentUser?.id == organizerId) return true;
    return false;
  }
  
  bool canCreateConference() {
    return isAdmin || isOrganizer || isClubPresident;
  }
  
  bool canEditConference(String organizerId) {
    if (isAdmin) return true;
    if (isOrganizer && _currentUser?.id == organizerId) return true;
    if (isClubPresident && _currentUser?.id == organizerId) return true;
    return false;
  }
  
  bool canDeleteConference(String organizerId) {
    if (isAdmin) return true;
    if (isOrganizer && _currentUser?.id == organizerId) return true;
    if (isClubPresident && _currentUser?.id == organizerId) return true;
    return false;
  }
  
  bool canCreateClub() {
    return isAdmin;
  }
  
  bool canEditClub(String presidentId) {
    if (isAdmin) return true;
    if (isClubPresident && _currentUser?.id == presidentId) return true;
    return false;
  }
  
  bool canDeleteClub(String presidentId) {
    if (isAdmin) return true;
    if (isClubPresident && _currentUser?.id == presidentId) return true;
    return false;
  }
  
  bool canManageClubMembers(String presidentId) {
    if (isAdmin) return true;
    if (isClubPresident && _currentUser?.id == presidentId) return true;
    return false;
  }

  bool canDeleteUser(String userId) {
    if (!isAdmin) return false;
    if (_currentUser?.id == userId) return false;
    return true;
  }

  bool canDeleteAllUsers() {
    return isAdmin;
  }

  // ─── Authentification ────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await loginUseCase(email, password);
      if (_currentUser != null) {
        _errorMessage = null;
        
        final notificationViewModel = getIt<NotificationViewModel>();
        notificationViewModel.setCurrentUser(_currentUser!.id);
        await notificationViewModel.loadNotifications();
        
        return true;
      } else {
        _errorMessage = 'Email ou mot de passe incorrect';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String fullName, {String role = 'student'}) async {
    _setLoading(true);
    try {
      _currentUser = await registerUseCase(email, password, fullName, role: role);
      if (_currentUser != null) {
        _errorMessage = null;
        
        final notificationViewModel = getIt<NotificationViewModel>();
        notificationViewModel.setCurrentUser(_currentUser!.id);
        await notificationViewModel.loadNotifications();
        
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Gestion des utilisateurs (Admin) ───────────────────────────

  Future<void> getAllUsers() async {
    _setLoading(true);
    try {
      _allUsers = await getAllUsersUseCase();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    try {
      final success = await deleteUserUseCase(userId);
      if (success) {
        _allUsers.removeWhere((u) => u.id == userId);
        _errorMessage = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAllUsers() async {
    _setLoading(true);
    try {
      final success = await deleteAllUsersUseCase();
      if (success) {
        _allUsers.clear();
        _errorMessage = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Gestion du profil ───────────────────────────────────────────

  // ✅ Mise à jour du profil (sans email)
  Future<bool> updateProfile(String fullName, String role, String? profileImage) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      final updatedUser = await updateProfileUseCase(
        userId: _currentUser!.id,
        fullName: fullName,
        role: role,
        profileImage: profileImage,
      );
      if (updatedUser != null) {
        _currentUser = updatedUser;
        _errorMessage = null;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ✅ Changement de mot de passe
  Future<bool> changePassword(String userId, String newPassword) async {
    _setLoading(true);
    try {
      final success = await changePasswordUseCase(userId, newPassword);
      if (success) {
        _errorMessage = null;
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Gestion des mots de passe ──────────────────────────────────

  Future<Map<String, dynamic>> sendResetCode(String email) async {
    _setLoading(true);
    try {
      final result = await sendResetCodeUseCase(email);
      _errorMessage = null;
      if (result['success'] == true) {
        _lastGeneratedCode = result['code'];
      } else {
        _errorMessage = result['message'];
      }
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return {
        'success': false,
        'message': e.toString(),
        'code': '',
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> sendResetCodeWithRole(String email, String role) async {
    _setLoading(true);
    try {
      final result = await sendResetCodeWithRoleUseCase(email, role);
      _errorMessage = null;
      if (result['success'] == true) {
        _lastGeneratedCode = result['code'];
      } else {
        _errorMessage = result['message'];
      }
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return {
        'success': false,
        'message': e.toString(),
        'code': '',
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmail(String userId, String newEmail) async {
  _setLoading(true);
  try {
    final success = await updateEmailUseCase(userId, newEmail);
    if (success) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(email: newEmail);
        _errorMessage = null;
        notifyListeners();
      }
    }
    return success;
  } catch (e) {
    _errorMessage = e.toString();
    return false;
  } finally {
    _setLoading(false);
  }
}

  Future<bool> verifyResetCode(String email, String code) async {
    _setLoading(true);
    try {
      final isValid = await verifyResetCodeUseCase(email, code);
      if (!isValid) {
        _errorMessage = 'Code invalide ou expiré';
      } else {
        _errorMessage = null;
      }
      return isValid;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPasswordWithCode(String email, String code, String newPassword) async {
    _setLoading(true);
    try {
      final success = await resetPasswordWithCodeUseCase(email, code, newPassword);
      if (success) {
        _errorMessage = null;
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Autres méthodes ─────────────────────────────────────────────

  void logout() {
    final notificationViewModel = getIt<NotificationViewModel>();
    notificationViewModel.clear();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}