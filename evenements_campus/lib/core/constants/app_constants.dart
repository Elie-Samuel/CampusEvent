class AppConstants {
  static const String databaseName = 'campus_event.db';
  static const int databaseVersion = 6;
  
  // Table names
  static const String tableUsers = 'users';
  static const String tableNotifications = 'notifications';
  static const String tableEvents = 'events';
  static const String tableClubs = 'clubs';
  static const String tableEventRegistrations = 'event_registrations';
  static const String tableClubMembers = 'club_members';
  static const String tablePasswordResetCodes = 'password_reset_codes';
  
  // Shared preferences keys
  static const String keyUserLoggedIn = 'user_logged_in';
  static const String keyCurrentUserId = 'current_user_id';
}

// Rôles utilisateur
enum UserRole {
  admin('admin', 'Administrateur'),
  organizer('organizer', 'Organisateur'),
  clubPresident('club_president', 'Chef de club'),
  student('student', 'Étudiant');

  final String value;
  final String label;
  
  const UserRole(this.value, this.label);
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.student,
    );
  }
}

// Permissions
class Permissions {
  static const String createEvent = 'create_event';
  static const String editEvent = 'edit_event';
  static const String deleteEvent = 'delete_event';
  static const String viewEvents = 'view_events';
  static const String createConference = 'create_conference';
  static const String editConference = 'edit_conference';
  static const String deleteConference = 'delete_conference';
  static const String createClub = 'create_club';
  static const String editClub = 'edit_club';
  static const String deleteClub = 'delete_club';
  static const String manageMembers = 'manage_members';
  
  static const Map<UserRole, List<String>> rolePermissions = {
    UserRole.admin: [
      createEvent, editEvent, deleteEvent, viewEvents,
      createConference, editConference, deleteConference,
      createClub, editClub, deleteClub, manageMembers,
    ],
    UserRole.organizer: [
      createEvent, editEvent, deleteEvent, viewEvents,
      createConference, editConference, deleteConference,
    ],
    UserRole.clubPresident: [
      viewEvents, editClub, manageMembers,
    ],
    UserRole.student: [
      viewEvents,
    ],
  };
  
  static bool hasPermission(UserRole role, String permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }
}