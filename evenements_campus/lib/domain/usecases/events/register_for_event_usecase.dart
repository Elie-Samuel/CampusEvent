import '../../repositories/event_repository.dart';

class RegisterForEventUseCase {
  final EventRepository repository;
  RegisterForEventUseCase(this.repository);
  
  Future<void> call(String eventId, String userId) async {
    if (eventId.isEmpty) throw Exception('ID événement requis');
    if (userId.isEmpty) throw Exception('ID utilisateur requis');
    
    final isRegistered = await repository.isUserRegistered(eventId, userId);
    if (isRegistered) throw Exception('Déjà inscrit à cet événement');
    
    await repository.registerForEvent(eventId, userId);
  }
}