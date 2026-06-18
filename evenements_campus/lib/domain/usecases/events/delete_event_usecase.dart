import '../../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository repository;

  DeleteEventUseCase(this.repository);

  Future<void> call(String eventId) async {
    if (eventId.isEmpty) throw Exception('ID événement requis');
    
    await repository.deleteEvent(eventId);
  }
}