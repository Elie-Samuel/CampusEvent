import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EventType {
  conference,
  workshop,
  club,
  sport,
  cultural,
  academic,
}

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String organizerId;
  final String organizerName;
  final EventType type;
  final int maxParticipants;
  final int currentParticipants;
  final String? imageUrl;
  final List<String> tags;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.organizerId,
    required this.organizerName,
    required this.type,
    required this.maxParticipants,
    required this.currentParticipants,
    this.imageUrl,
    this.tags = const [],
    this.status = 'upcoming',
  });

  String get formattedDate => DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
  String get formattedTimeRange => '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
  String get participantsText => '$currentParticipants / $maxParticipants participants';
  bool get isAvailable => currentParticipants < maxParticipants;
  bool get isFull => currentParticipants >= maxParticipants;
  double get participationRate => maxParticipants == 0 ? 0 : currentParticipants / maxParticipants;
  bool get isConference => type == EventType.conference;

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? organizerId,
    String? organizerName,
    EventType? type,
    int? maxParticipants,
    int? currentParticipants,
    String? imageUrl,
    List<String>? tags,
    String? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      type: type ?? this.type,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'type': type.toString().split('.').last,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'image_url': imageUrl,
      'tags': tags.join(','),
      'status': status,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'].toString(),
      title: map['title'].toString(),
      description: map['description'].toString(),
      location: map['location'].toString(),
      date: DateTime.parse(map['date'].toString()),
      startTime: DateTime.parse(map['start_time'].toString()),
      endTime: DateTime.parse(map['end_time'].toString()),
      organizerId: map['organizer_id'].toString(),
      organizerName: map['organizer_name'].toString(),
      type: _stringToEventType(map['type'].toString()),
      maxParticipants: map['max_participants'] as int,
      currentParticipants: map['current_participants'] as int,
      imageUrl: map['image_url']?.toString(),
      tags: map['tags']?.toString().split(',') ?? [],
      status: map['status']?.toString() ?? 'upcoming',
    );
  }

  static EventType _stringToEventType(String type) {
    switch (type) {
      case 'conference': return EventType.conference;
      case 'workshop': return EventType.workshop;
      case 'club': return EventType.club;
      case 'sport': return EventType.sport;
      case 'cultural': return EventType.cultural;
      case 'academic': return EventType.academic;
      default: return EventType.conference;
    }
  }
}

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.conference: return 'Conférence';
      case EventType.workshop: return 'Atelier';
      case EventType.club: return 'Club';
      case EventType.sport: return 'Sport';
      case EventType.cultural: return 'Culturel';
      case EventType.academic: return 'Académique';
    }
  }
  IconData get icon {
    switch (this) {
      case EventType.conference: return Icons.mic;
      case EventType.workshop: return Icons.build;
      case EventType.club: return Icons.people;
      case EventType.sport: return Icons.sports_soccer;
      case EventType.cultural: return Icons.palette;
      case EventType.academic: return Icons.school;
    }
  }
}