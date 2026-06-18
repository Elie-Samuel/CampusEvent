import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/event.dart';
import '../datasources/local/app_database.dart';
import '../../core/constants/app_constants.dart';

class EventRepositoryImpl implements EventRepository {
  final AppDatabase appDatabase;

  EventRepositoryImpl(this.appDatabase);

  Future<Database> get _db async => await appDatabase.database;

  @override
  Future<List<Event>> getUpcomingEvents() async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final results = await db.query(
      AppConstants.tableEvents,
      where: 'date > ? AND status = ?',
      whereArgs: [now, 'upcoming'],
      orderBy: 'date ASC',
    );
    return results.map((e) => Event.fromMap(e)).toList();
  }

  @override
  Future<List<Event>> getEventsByType(String type) async {
    final db = await _db;
    final results = await db.query(
      AppConstants.tableEvents,
      where: 'type = ?',
      whereArgs: [type],
    );
    return results.map((e) => Event.fromMap(e)).toList();
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    final db = await _db;
    final registrations = await db.query(
      AppConstants.tableEventRegistrations,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    final List<Event> events = [];
    for (var reg in registrations) {
      final eventId = reg['event_id'] as String;
      final eventResult = await db.query(
        AppConstants.tableEvents,
        where: 'id = ?',
        whereArgs: [eventId],
      );
      if (eventResult.isNotEmpty) {
        events.add(Event.fromMap(eventResult.first));
      }
    }
    return events;
  }

  @override
  Future<void> registerForEvent(String eventId, String userId) async {
    final db = await _db;
    
    // Vérifier si déjà inscrit
    final existing = await db.query(
      AppConstants.tableEventRegistrations,
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
    
    if (existing.isNotEmpty) return;
    
    await db.insert(
      AppConstants.tableEventRegistrations,
      {
        'event_id': eventId,
        'user_id': userId,
        'registered_at': DateTime.now().toIso8601String(),
      },
    );
    
    // Mettre à jour le compteur de participants
    final event = await db.query(
      AppConstants.tableEvents,
      where: 'id = ?',
      whereArgs: [eventId],
    );
    if (event.isNotEmpty) {
      final currentParticipants = event.first['current_participants'] as int;
      await db.update(
        AppConstants.tableEvents,
        {'current_participants': currentParticipants + 1},
        where: 'id = ?',
        whereArgs: [eventId],
      );
    }
  }

  @override
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    final db = await _db;
    
    await db.delete(
      AppConstants.tableEventRegistrations,
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
    
    // Mettre à jour le compteur de participants
    final event = await db.query(
      AppConstants.tableEvents,
      where: 'id = ?',
      whereArgs: [eventId],
    );
    if (event.isNotEmpty) {
      final currentParticipants = event.first['current_participants'] as int;
      await db.update(
        AppConstants.tableEvents,
        {'current_participants': currentParticipants - 1},
        where: 'id = ?',
        whereArgs: [eventId],
      );
    }
  }

  @override
  Future<void> createEvent(Event event) async {
    final db = await _db;
    await db.insert(AppConstants.tableEvents, event.toMap());
  }

  @override
  Future<void> updateEvent(Event event) async {
    final db = await _db;
    await db.update(
      AppConstants.tableEvents,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final db = await _db;
    await db.delete(
      AppConstants.tableEventRegistrations,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    await db.delete(
      AppConstants.tableEvents,
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  @override
  Future<bool> isUserRegistered(String eventId, String userId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableEventRegistrations,
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<int> getParticipantCount(String eventId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableEventRegistrations,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return result.length;
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    final db = await _db;
    final result = await db.query(
      AppConstants.tableEvents,
      where: 'id = ?',
      whereArgs: [eventId],
    );
    if (result.isEmpty) return null;
    return Event.fromMap(result.first);
  }
}