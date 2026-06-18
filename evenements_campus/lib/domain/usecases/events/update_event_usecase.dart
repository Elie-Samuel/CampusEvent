import '../../repositories/event_repository.dart';
import '../../entities/event.dart';

class UpdateEventUseCase {
  final EventRepository repository;

  UpdateEventUseCase(this.repository);

  Future<void> call(Event event) async {
    if (event.title.isEmpty) throw Exception('Le titre est requis');
    if (event.description.isEmpty) throw Exception('La description est requise');
    if (event.location.isEmpty) throw Exception('Le lieu est requis');
    if (event.maxParticipants <= 0) throw Exception('Le nombre de participants doit être supérieur à 0');
    
    await repository.updateEvent(event);
  }
}