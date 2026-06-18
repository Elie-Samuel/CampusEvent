import '../../repositories/event_repository.dart';
import '../../entities/event.dart';

class GetUpcomingEventsUseCase {
  final EventRepository repository;
  GetUpcomingEventsUseCase(this.repository);
  Future<List<Event>> call() => repository.getUpcomingEvents();
}

class GetEventsByTypeUseCase {
  final EventRepository repository;
  GetEventsByTypeUseCase(this.repository);
  Future<List<Event>> call(String type) => repository.getEventsByType(type);
}

class GetUserEventsUseCase {
  final EventRepository repository;
  GetUserEventsUseCase(this.repository);
  Future<List<Event>> call(String userId) => repository.getUserEvents(userId);
}

class GetEventByIdUseCase {
  final EventRepository repository;
  GetEventByIdUseCase(this.repository);
  Future<Event?> call(String id) => repository.getEventById(id);
}