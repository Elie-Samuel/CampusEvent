import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/constants/app_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    String path;
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, AppConstants.databaseName);
    } else {
      path = join(Directory.current.path, AppConstants.databaseName);
    }
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        profile_image TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Notifications table avec user_id
    await db.execute('''
      CREATE TABLE ${AppConstants.tableNotifications} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        related_id TEXT,
        created_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        image_url TEXT,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id)
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableEvents} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        organizer_id TEXT NOT NULL,
        organizer_name TEXT NOT NULL,
        type TEXT NOT NULL,
        max_participants INTEGER NOT NULL,
        current_participants INTEGER NOT NULL,
        image_url TEXT,
        tags TEXT,
        status TEXT DEFAULT 'upcoming',
        FOREIGN KEY (organizer_id) REFERENCES ${AppConstants.tableUsers} (id)
      )
    ''');

    // Clubs table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableClubs} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        president_id TEXT NOT NULL,
        president_name TEXT NOT NULL,
        member_count INTEGER NOT NULL,
        logo_url TEXT,
        social_links TEXT,
        status TEXT DEFAULT 'active',
        FOREIGN KEY (president_id) REFERENCES ${AppConstants.tableUsers} (id)
      )
    ''');

    // Event registrations table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableEventRegistrations} (
        event_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        registered_at TEXT NOT NULL,
        status TEXT DEFAULT 'confirmed',
        PRIMARY KEY (event_id, user_id),
        FOREIGN KEY (event_id) REFERENCES ${AppConstants.tableEvents} (id),
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id)
      )
    ''');

    // Club members table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableClubMembers} (
        club_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        role TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        PRIMARY KEY (club_id, user_id),
        FOREIGN KEY (club_id) REFERENCES ${AppConstants.tableClubs} (id),
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id)
      )
    ''');

    // Password reset codes table
    await db.execute('''
      CREATE TABLE ${AppConstants.tablePasswordResetCodes} (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        code TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        used INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    // Admin user - NOUVEAUX IDENTIFIANTS
    await db.insert(AppConstants.tableUsers, {
      'id': '1',
      'email': 'admin@gmail.com',
      'password': 'eliesamuel',
      'full_name': 'Administrateur',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Organizer user
    await db.insert(AppConstants.tableUsers, {
      'id': '2',
      'email': 'organisateur@campus.com',
      'password': 'org123',
      'full_name': 'Organisateur Test',
      'role': 'organizer',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Club president user
    await db.insert(AppConstants.tableUsers, {
      'id': '3',
      'email': 'president@campus.com',
      'password': 'pres123',
      'full_name': 'Chef de Club',
      'role': 'club_president',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Student user for testing
    await db.insert(AppConstants.tableUsers, {
      'id': '4',
      'email': 'etudiant@campus.com',
      'password': 'etudiant123',
      'full_name': 'Étudiant Test',
      'role': 'student',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Sample clubs
    final clubs = [
      {'id': '1', 'name': 'Club Informatique', 'description': 'Club dédié à la programmation', 'category': 'Technologie', 'president_id': '3', 'president_name': 'Chef de Club', 'member_count': 45},
      {'id': '2', 'name': 'Club Sportif', 'description': 'Club pour les amateurs de sport', 'category': 'Sport', 'president_id': '1', 'president_name': 'Administrateur', 'member_count': 78},
      {'id': '3', 'name': 'Club Culturel', 'description': 'Club pour les activités culturelles', 'category': 'Culture', 'president_id': '1', 'president_name': 'Administrateur', 'member_count': 32},
    ];
    for (var club in clubs) {
      await db.insert(AppConstants.tableClubs, club);
    }

    // Sample events
    final now = DateTime.now();
    final events = [
      {'id': '1', 'title': 'Conférence Tech 2026', 'description': 'Grande conférence sur les technologies', 'location': 'Grand Amphi', 'date': now.add(const Duration(days: 7)).toIso8601String(), 'start_time': now.add(const Duration(days: 7, hours: 14)).toIso8601String(), 'end_time': now.add(const Duration(days: 7, hours: 17)).toIso8601String(), 'organizer_id': '2', 'organizer_name': 'Organisateur Test', 'type': 'conference', 'max_participants': 100, 'current_participants': 45, 'tags': 'tech', 'status': 'upcoming'},
      {'id': '2', 'title': 'Tournoi de Football', 'description': 'Tournoi inter-facultés', 'location': 'Stade', 'date': now.add(const Duration(days: 14)).toIso8601String(), 'start_time': now.add(const Duration(days: 14, hours: 9)).toIso8601String(), 'end_time': now.add(const Duration(days: 14, hours: 12)).toIso8601String(), 'organizer_id': '2', 'organizer_name': 'Organisateur Test', 'type': 'sport', 'max_participants': 50, 'current_participants': 30, 'tags': 'sport', 'status': 'upcoming'},
    ];
    for (var event in events) {
      await db.insert(AppConstants.tableEvents, event);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableNotifications} ADD COLUMN user_id TEXT');
        await db.execute('''
          UPDATE ${AppConstants.tableNotifications} 
          SET user_id = '1' 
          WHERE user_id IS NULL
        ''');
      } catch (e) {
        print('Migration error: $e');
      }
    }
    
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE ${AppConstants.tableEvents} ADD COLUMN status TEXT DEFAULT "upcoming"');
        await db.execute('ALTER TABLE ${AppConstants.tableClubs} ADD COLUMN status TEXT DEFAULT "active"');
        await db.execute('ALTER TABLE ${AppConstants.tableEventRegistrations} ADD COLUMN status TEXT DEFAULT "confirmed"');
        await db.execute('ALTER TABLE ${AppConstants.tableClubMembers} ADD COLUMN status TEXT DEFAULT "active"');
      } catch (e) {
        print('Migration error to version 5: $e');
      }
    }
  }
}