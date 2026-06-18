// lib/domain/repositories/auth_repository.dart

import '../../data/models/user_model.dart';
import 'dart:io';

abstract class AuthRepository {
  // Authentification
  Future<UserModel?> login(String email, String password);
  Future<UserModel> register(String email, String password, String fullName, {String role = 'student'});
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getCurrentUser();
  
  // Gestion du profil
  Future<UserModel?> updateProfile(String userId, String fullName, String role, String? profileImage);
  Future<String?> uploadProfileImage(File imageFile);
  Future<void> deleteProfileImage(String userId);
  
  // Changement de mot de passe
  Future<bool> changePassword(String userId, String newPassword);
  Future<bool> updateEmail(String userId, String newEmail);
  
  // Gestion des mots de passe
  Future<Map<String, dynamic>> sendResetCode(String email);
  Future<Map<String, dynamic>> sendResetCodeWithRole(String email, String role);
  Future<bool> verifyResetCode(String email, String code);
  Future<bool> resetPasswordWithCode(String email, String code, String newPassword);
  
  // Gestion des utilisateurs (Admin)
  Future<List<UserModel>> getAllUsers();
  Future<bool> deleteUser(String userId);
  Future<bool> deleteAllUsers();
}