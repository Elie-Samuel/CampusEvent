import '../../core/constants/app_constants.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      email: map['email'].toString(),
      fullName: map['full_name'].toString(),
      role: UserRole.fromString(map['role'].toString()),
      profileImage: map['profile_image']?.toString(),
      createdAt: DateTime.parse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.value,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  bool get isAdmin => role == UserRole.admin;
  bool get isOrganizer => role == UserRole.organizer;
  bool get isClubPresident => role == UserRole.clubPresident;
  bool get isStudent => role == UserRole.student;
  
  bool canCreateEvent() => Permissions.hasPermission(role, Permissions.createEvent);
  bool canEditEvent(String eventOrganizerId) => isAdmin || (isOrganizer && eventOrganizerId == id);
  bool canDeleteEvent(String eventOrganizerId) => isAdmin || (isOrganizer && eventOrganizerId == id);
  bool canCreateConference() => Permissions.hasPermission(role, Permissions.createConference);
  bool canEditConference(String eventOrganizerId) => isAdmin || (isOrganizer && eventOrganizerId == id);
  bool canCreateClub() => Permissions.hasPermission(role, Permissions.createClub);
  bool canEditClub(String clubPresidentId) => isAdmin || (isClubPresident && clubPresidentId == id);
  bool canDeleteClub(String clubPresidentId) => isAdmin || (isClubPresident && clubPresidentId == id);
  bool canManageClubMembers(String clubPresidentId) => isAdmin || (isClubPresident && clubPresidentId == id);
}