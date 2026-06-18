import '../../domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.organizerId,
    required super.organizerName,
    required super.type,
    required super.maxParticipants,
    required super.currentParticipants,
    super.imageUrl,
    super.tags,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'].toString(),
      title: map['title'].toString(),
      description: map['description'].toString(),
      location: map['location'].toString(),
      date: DateTime.parse(map['date'].toString()),
      startTime: DateTime.parse(map['start_time'].toString()),
      endTime: DateTime.parse(map['end_time'].toString()),
      organizerId: map['organizer_id'].toString(),
      organizerName: map['organizer_name'].toString(),
      type: _parseEventType(map['type'].toString()),
      maxParticipants: map['max_participants'] as int,
      currentParticipants: map['current_participants'] as int,
      imageUrl: map['image_url']?.toString(),
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : [],
    );
  }

  static EventModel fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      location: event.location,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      organizerId: event.organizerId,
      organizerName: event.organizerName,
      type: event.type,
      maxParticipants: event.maxParticipants,
      currentParticipants: event.currentParticipants,
      imageUrl: event.imageUrl,
      tags: event.tags,
    );
  }

  static EventType _parseEventType(String type) {
    return EventType.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == type.toUpperCase(),
      orElse: () => EventType.values.first,
    );
  }
}