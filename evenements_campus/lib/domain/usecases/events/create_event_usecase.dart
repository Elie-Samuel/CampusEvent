import '../../entities/event.dart';
import '../../repositories/event_repository.dart';

class CreateEventUseCase {
  final EventRepository repository;
  CreateEventUseCase(this.repository);
  Future<void> call(Event event) => repository.createEvent(event);
}