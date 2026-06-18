// lib/data/models/user_model.dart

import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'].toString(),
      email: map['email'].toString(),
      fullName: map['full_name'].toString(),
      role: map['role'].toString(),
      profileImage: map['profile_image']?.toString(),
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ✅ MÉTHODE COPYWITH AJOUTÉE
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      role: UserRole.fromString(role),
      profileImage: profileImage,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromDomain(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role.value,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
    );
  }
}