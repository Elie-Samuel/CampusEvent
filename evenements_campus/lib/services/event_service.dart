import '../models/event.dart';

class EventService {
  List<Event> _events = [];
  
  EventService() {
    _loadDefaultEvents();
  }
  
  void _loadDefaultEvents() {
    final now = DateTime.now();
    _events = [
      Event(
        id: '1',
        title: 'Conférence Tech 2026',
        description: 'Une conférence sur les dernières technologies du développement mobile.',
        location: 'Grand Amphi, Campus Principal',
        date: now.add(const Duration(days: 7)),
        time: '14:00',
        organizer: 'Club Informatique',
        category: 'Conférence',
        maxParticipants: 100,
        currentParticipants: 45,
      ),
      Event(
        id: '2',
        title: 'Tournoi de Football',
        description: 'Tournoi inter-facultés de football. Venez représenter votre département!',
        location: 'Stade Universitaire',
        date: now.add(const Duration(days: 14)),
        time: '09:00',
        organizer: 'Association Sportive',
        category: 'Sport',
        maxParticipants: 50,
        currentParticipants: 30,
      ),
      Event(
        id: '3',
        title: 'Soirée Culturelle',
        description: 'Soirée avec spectacles, musique et danses traditionnelles.',
        location: 'Espace Culturel',
        date: now.add(const Duration(days: 10)),
        time: '18:00',
        organizer: 'Club Culturel',
        category: 'Culturel',
        maxParticipants: 200,
        currentParticipants: 120,
      ),
      Event(
        id: '4',
        title: 'Atelier Flutter',
        description: 'Apprenez à développer des applications mobiles avec Flutter.',
        location: 'Salle Info 101',
        date: now.add(const Duration(days: 5)),
        time: '10:00',
        organizer: 'GDG Campus',
        category: 'Atelier',
        maxParticipants: 30,
        currentParticipants: 25,
      ),
    ];
  }
  
  Future<List<Event>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _events;
  }
  
  Future<void> registerForEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _events[index];
      if (event.isAvailable) {
        _events[index] = Event(
          id: event.id,
          title: event.title,
          description: event.description,
          location: event.location,
          date: event.date,
          time: event.time,
          organizer: event.organizer,
          category: event.category,
          maxParticipants: event.maxParticipants,
          currentParticipants: event.currentParticipants + 1,
        );
      }
    }
  }
  
  Future<void> addEvent(Event event) async {
    _events.add(event);
  }
}