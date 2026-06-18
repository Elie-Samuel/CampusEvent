import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/events/get_events_usecase.dart';
import '../../domain/usecases/events/register_for_event_usecase.dart';
import '../../domain/usecases/events/create_event_usecase.dart';
import '../../domain/usecases/events/update_event_usecase.dart';
import '../../domain/usecases/events/delete_event_usecase.dart';
import '../../domain/usecases/events/unregister_from_event_usecase.dart';
import '../../services/notification_service.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'auth_viewmodel.dart';

final getIt = GetIt.instance;

class EventViewModel extends ChangeNotifier {
  final GetUpcomingEventsUseCase getUpcomingEventsUseCase;
  final GetEventsByTypeUseCase getEventsByTypeUseCase;
  final RegisterForEventUseCase registerForEventUseCase;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final UnregisterFromEventUseCase unregisterFromEventUseCase;
  final GetUserEventsUseCase getUserEventsUseCase;

  List<Event> _upcomingEvents = [];
  final Map<EventType, List<Event>> _eventsByType = {};
  List<Event> _userEvents = [];
  EventType? _selectedType;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProcessing = false;

  EventViewModel({
    required this.getUpcomingEventsUseCase,
    required this.getEventsByTypeUseCase,
    required this.registerForEventUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.unregisterFromEventUseCase,
    required this.getUserEventsUseCase,
  });

  List<Event> get upcomingEvents => _upcomingEvents;
  Map<EventType, List<Event>> get eventsByType => _eventsByType;
  List<Event> get userEvents => _userEvents;
  EventType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Event> get filteredEvents {
    List<Event> list = _selectedType == null 
        ? _upcomingEvents 
        : (_eventsByType[_selectedType] ?? []);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((e) =>
          e.title.toLowerCase().contains(query) ||
          e.description.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query) ||
          e.tags.any((t) => t.toLowerCase().contains(query))
      ).toList();
    }
    return list;
  }

  List<Event> get conferences => _upcomingEvents.where((e) => e.isConference).toList();

  // Méthodes de permission
  bool canEditEvent(String organizerId) {
    final auth = getIt<AuthViewModel>();
    return auth.canEditEvent(organizerId);
  }

  bool canDeleteEvent(String organizerId) {
    final auth = getIt<AuthViewModel>();
    return auth.canDeleteEvent(organizerId);
  }

  Future<void> loadUpcomingEvents() async {
    _setLoading(true);
    try {
      _upcomingEvents = await getUpcomingEventsUseCase();
      _errorMessage = null;
      await loadEventsByType();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEventsByType() async {
    try {
      for (var type in EventType.values) {
        final events = await getEventsByTypeUseCase(type.toString().split('.').last);
        _eventsByType[type] = events;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadUserEvents(String userId) async {
    if (userId.isEmpty) return;
    try {
      _userEvents = await getUserEventsUseCase(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void filterByType(EventType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> registerForEvent(String eventId, String userId) async {
    if (_isProcessing) return false;
    _isProcessing = true;
    _setLoading(true);
    try {
      await registerForEventUseCase(eventId, userId);
      await loadUpcomingEvents();
      await loadUserEvents(userId);
      
      final event = getEventById(eventId);
      if (event != null) {
        final notificationService = NotificationService();
        await notificationService.showRegistrationConfirmation(eventId: eventId, eventTitle: event.title);
        
        final notificationViewModel = getIt<NotificationViewModel>();
        final alreadyExists = notificationViewModel.notifications.any(
          (n) => n.relatedId == eventId && n.type == 'registration_confirmation'
        );
        
        if (!alreadyExists) {
          final notification = AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            title: 'Inscription confirmée',
            body: 'Vous êtes inscrit à "${event.title}"',
            type: 'registration_confirmation',
            relatedId: eventId,
            createdAt: DateTime.now(),
          );
          await notificationViewModel.addNotification(notification);
        }
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
      _isProcessing = false;
    }
  }

  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    if (_isProcessing) return false;
    _isProcessing = true;
    _setLoading(true);
    try {
      await unregisterFromEventUseCase(eventId, userId);
      await loadUpcomingEvents();
      await loadUserEvents(userId);
      
      final event = getEventById(eventId);
      if (event != null) {
        final notificationService = NotificationService();
        await notificationService.showRegistrationCancelled(eventId: eventId, eventTitle: event.title);
        
        final notificationViewModel = getIt<NotificationViewModel>();
        final alreadyExists = notificationViewModel.notifications.any(
          (n) => n.relatedId == eventId && n.type == 'registration_cancelled'
        );
        
        if (!alreadyExists) {
          final notification = AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            title: 'Inscription annulée',
            body: 'Vous vous êtes désinscrit de "${event.title}"',
            type: 'registration_cancelled',
            relatedId: eventId,
            createdAt: DateTime.now(),
          );
          await notificationViewModel.addNotification(notification);
        }
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
      _isProcessing = false;
    }
  }

  Future<bool> createEvent(Event event) async {
    _setLoading(true);
    try {
      await createEventUseCase(event);
      await loadUpcomingEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Ajoutez ces méthodes à la fin de la classe EventViewModel

// Gestion des événements (pour l'admin)
List<Event> _allEvents = [];

List<Event> get allEvents => _allEvents;

Future<void> getAllEvents() async {
  _setLoading(true);
  try {
    // Utiliser la méthode existante pour charger tous les événements
    // Puisque nous avons déjà loadUpcomingEvents qui charge tout
    await loadUpcomingEvents();
    _allEvents = _upcomingEvents;
    _errorMessage = null;
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _setLoading(false);
  }
}

  Future<bool> updateEvent(Event event) async {
    _setLoading(true);
    try {
      await updateEventUseCase(event);
      await loadUpcomingEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    _setLoading(true);
    try {
      await deleteEventUseCase(eventId);
      await loadUpcomingEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool isRegistered(String eventId) => _userEvents.any((e) => e.id == eventId);
  
  Event? getEventById(String id) {
    try {
      return _upcomingEvents.firstWhere((e) => e.id == id);
    } catch (e) {
      try {
        return _userEvents.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}