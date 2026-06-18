// lib/data/repositories/auth_repository_impl.dart

import 'dart:io';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/app_database.dart';
import '../models/user_model.dart';
import '../../services/email_service.dart';
import '../../services/image_upload_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AppDatabase appDatabase;
  final ImageUploadService _imageUploadService = ImageUploadService();

  AuthRepositoryImpl(this.appDatabase);

  Future<Database> get _db async => await appDatabase.database;

  // ─── Authentification ────────────────────────────────────────────

  @override
  Future<UserModel?> login(String email, String password) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  // CORRECTION : Le rôle est maintenant sauvegardé correctement
  @override
  Future<UserModel> register(String email, String password, String fullName, {String role = 'student'}) async {
    final db = await _db;
    
    final existing = await db.query(
      AppConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (existing.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }
    
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      fullName: fullName,
      role: role, // Le rôle est maintenant utilisé
      createdAt: DateTime.now(),
    );
    
    await db.insert(AppConstants.tableUsers, {
      ...user.toMap(),
      'password': password,
    });
    
    return user;
  }

  @override
Future<bool> updateEmail(String userId, String newEmail) async {
  final db = await _db;
  try {
    // Vérifier si l'email existe déjà (unicité)
    final existing = await db.query(
      AppConstants.tableUsers,
      where: 'email = ? AND id != ?',
      whereArgs: [newEmail, userId],
    );
    
    if (existing.isNotEmpty) {
      print('[AUTH] Email déjà utilisé: $newEmail');
      return false;
    }
    
    // Mettre à jour l'email
    final updated = await db.update(
      AppConstants.tableUsers,
      {'email': newEmail},
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    print('[AUTH] Email mis à jour pour l\'utilisateur: $userId');
    return updated > 0;
    
  } catch (e) {
    print('[AUTH] Erreur lors de la mise à jour de l\'email: $e');
    return false;
  }
}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final db = await _db;
      final result = await db.query(
        AppConstants.tableUsers,
        limit: 1,
      );
      if (result.isEmpty) return null;
      return UserModel.fromMap(result.first);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // ─── Gestion des utilisateurs (Admin) ───────────────────────────

  @override
  Future<List<UserModel>> getAllUsers() async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableUsers,
      orderBy: 'full_name ASC',
    );
    return result.map((json) => UserModel.fromMap(json)).toList();
  }

  // ─── Gestion du profil ───────────────────────────────────────────

  @override
  Future<UserModel?> updateProfile(String userId, String fullName, String role, String? profileImage) async {
    final db = await _db;
    
    final existing = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (existing.isEmpty) {
      throw Exception('Utilisateur non trouvé');
    }
    
    final Map<String, dynamic> updateData = {
      'full_name': fullName,
      'role': role,
    };
    
    if (profileImage != null) {
      updateData['profile_image'] = profileImage;
    }
    
    await db.update(
      AppConstants.tableUsers,
      updateData,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    final updated = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (updated.isEmpty) return null;
    return UserModel.fromMap(updated.first);
  }

  @override
  Future<String?> uploadProfileImage(File imageFile) async {
    return await _imageUploadService.saveProfileImage(imageFile);
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    final db = await _db;
    
    final user = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (user.isNotEmpty) {
      final currentUser = UserModel.fromMap(user.first);
      if (currentUser.profileImage != null) {
        await _imageUploadService.deleteProfileImage(currentUser.profileImage);
        
        await db.update(
          AppConstants.tableUsers,
          {'profile_image': null},
          where: 'id = ?',
          whereArgs: [userId],
        );
      }
    }
  }

  // ─── Gestion des mots de passe ──────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendResetCode(String email) async {
    return await sendResetCodeWithRole(email, '');
  }

  @override
  Future<Map<String, dynamic>> sendResetCodeWithRole(String email, String role) async {
    final db = await _db;
    
    print('[AUTH] Vérification de l\'email: $email avec rôle: $role');
    
    List<Object?> whereArgs = [email];
    String whereClause = 'email = ?';
    
    if (role.isNotEmpty) {
      whereClause += ' AND role = ?';
      whereArgs.add(role);
    }
    
    final user = await db.query(
      AppConstants.tableUsers,
      where: whereClause,
      whereArgs: whereArgs,
    );
    
    if (user.isEmpty) {
      print('[AUTH] Email non trouvé pour le rôle demandé: $email');
      return {
        'success': false,
        'message': role.isNotEmpty 
            ? 'Aucun compte ${_getRoleLabel(role)} associé à cet email' 
            : 'Aucun compte associé à cet email',
        'code': '',
      };
    }
    
    final userName = user.first['full_name'] as String;
    final userRole = user.first['role'] as String;
    final code = _generateResetCode();
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));
    
    print('[AUTH] Code généré: $code pour $email');
    
    await db.delete(
      AppConstants.tablePasswordResetCodes,
      where: 'email = ?',
      whereArgs: [email],
    );
    
    await db.insert(
      AppConstants.tablePasswordResetCodes,
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'code': code,
        'expires_at': expiresAt.toIso8601String(),
        'used': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    
    print('[AUTH] Code sauvegardé en base de données');
    
    final result = await EmailService.sendResetCodeEmail(email, code, userName, userRole);
    
    print('═══════════════════════════════════════════════════════════');
    print('DEMANDE DE RÉINITIALISATION');
    print('Email: $email');
    print('Nom: $userName');
    print('Rôle: $userRole');
    print('Code: $code');
    print('Email envoyé: ${result['success']}');
    print('═══════════════════════════════════════════════════════════');
    
    if (result['success'] == true) {
      return {
        'success': true,
        'message': 'Un code de réinitialisation a été envoyé à votre email',
        'code': code,
      };
    } else {
      return {
        'success': false,
        'message': result['message'],
        'code': code,
      };
    }
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    final db = await _db;
    print('[AUTH] Vérification du code $code pour $email');
    
    final result = await db.query(
      AppConstants.tablePasswordResetCodes,
      where: 'email = ? AND code = ? AND used = 0 AND expires_at > ?',
      whereArgs: [email, code, DateTime.now().toIso8601String()],
    );
    
    final isValid = result.isNotEmpty;
    print(isValid ? '[AUTH] Code valide' : '[AUTH] Code invalide ou expiré');
    return isValid;
  }

  @override
  Future<bool> resetPasswordWithCode(String email, String code, String newPassword) async {
    final db = await _db;
    print('[AUTH] Réinitialisation du mot de passe pour $email');
    
    final resetRecord = await db.query(
      AppConstants.tablePasswordResetCodes,
      where: 'email = ? AND code = ? AND used = 0 AND expires_at > ?',
      whereArgs: [email, code, DateTime.now().toIso8601String()],
    );
    
    if (resetRecord.isEmpty) {
      print('[AUTH] Code invalide ou expiré');
      throw Exception('Code invalide ou expiré');
    }
    
    final updated = await db.update(
      AppConstants.tableUsers,
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (updated == 0) {
      print('[AUTH] Erreur lors de la mise à jour');
      throw Exception('Erreur lors de la mise à jour');
    }
    
    await db.update(
      AppConstants.tablePasswordResetCodes,
      {'used': 1},
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
    );
    
    print('[AUTH] Mot de passe réinitialisé avec succès');
    return true;
  }

  @override
Future<bool> changePassword(String userId, String newPassword) async {
  final db = await _db;
  try {
    // Vérifier si l'utilisateur existe
    final user = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (user.isEmpty) {
      print('[AUTH] Utilisateur non trouvé: $userId');
      return false;
    }
    
    // Mettre à jour le mot de passe
    final updated = await db.update(
      AppConstants.tableUsers,
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    print('[AUTH] Mot de passe mis à jour pour l\'utilisateur: $userId');
    return updated > 0;
    
  } catch (e) {
    print('[AUTH] Erreur lors du changement de mot de passe: $e');
    return false;
  }
}

  // ─── SUPPRESSION DE COMPTES ─────────────────────────────────────

  @override
  Future<bool> deleteUser(String userId) async {
    final db = await _db;
    try {
      final user = await db.query(
        AppConstants.tableUsers,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (user.isEmpty) {
        print('[AUTH] Utilisateur non trouvé: $userId');
        return false;
      }
      
      final userData = UserModel.fromMap(user.first);
      
      if (userData.email == 'admin@gmail.com') {
        print('[AUTH] Impossible de supprimer l\'admin principal');
        return false;
      }
      
      await db.delete(
        AppConstants.tableNotifications,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      await db.delete(
        AppConstants.tableEventRegistrations,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      await db.delete(
        AppConstants.tableClubMembers,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      if (userData.profileImage != null) {
        await _imageUploadService.deleteProfileImage(userData.profileImage!);
      }
      
      final deleted = await db.delete(
        AppConstants.tableUsers,
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      print('[AUTH] Utilisateur supprimé avec succès: ${userData.email}');
      return deleted > 0;
      
    } catch (e) {
      print('[AUTH] Erreur lors de la suppression: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAllUsers() async {
    final db = await _db;
    try {
      final users = await db.query(
        AppConstants.tableUsers,
        where: 'email != ?',
        whereArgs: ['admin@gmail.com'],
      );
      
      if (users.isEmpty) {
        print('ℹ️ [AUTH] Aucun utilisateur à supprimer');
        return true;
      }
      
      for (var user in users) {
        final userId = user['id'] as String;
        
        await db.delete(
          AppConstants.tableNotifications,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        await db.delete(
          AppConstants.tableEventRegistrations,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        await db.delete(
          AppConstants.tableClubMembers,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        final userData = UserModel.fromMap(user);
        if (userData.profileImage != null) {
          await _imageUploadService.deleteProfileImage(userData.profileImage!);
        }
      }
      
      final deleted = await db.delete(
        AppConstants.tableUsers,
        where: 'email != ?',
        whereArgs: ['admin@gmail.com'],
      );
      
      print('✅ [AUTH] ${deleted} utilisateurs supprimés avec succès');
      return true;
      
    } catch (e) {
      print('❌ [AUTH] Erreur lors de la suppression de tous: $e');
      return false;
    }
  }

  // ─── Méthodes privées ────────────────────────────────────────────

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrateur';
      case 'organizer': return 'Organisateur';
      case 'club_president': return 'Chef de club';
      default: return 'Étudiant';
    }
  }

  String _generateResetCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10).toString()).join();
  }
}