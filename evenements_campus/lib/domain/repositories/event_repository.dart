import '../../domain/entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getUpcomingEvents();
  Future<List<Event>> getEventsByType(String type);
  Future<List<Event>> getUserEvents(String userId);
  Future<void> registerForEvent(String eventId, String userId);
  Future<void> unregisterFromEvent(String eventId, String userId);
  Future<void> createEvent(Event event);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<bool> isUserRegistered(String eventId, String userId);
  Future<int> getParticipantCount(String eventId);
  Future<Event?> getEventById(String eventId);
}