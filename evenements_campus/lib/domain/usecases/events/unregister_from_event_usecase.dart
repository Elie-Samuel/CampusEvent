import '../../repositories/event_repository.dart';

class UnregisterFromEventUseCase {
  final EventRepository repository;

  UnregisterFromEventUseCase(this.repository);

  Future<void> call(String eventId, String userId) async {
    if (eventId.isEmpty) throw Exception("ID de l'événement requis");
    if (userId.isEmpty) throw Exception("ID de l'utilisateur requis");
    return repository.unregisterFromEvent(eventId, userId);
  }
}
