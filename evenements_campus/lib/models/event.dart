class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final String organizer;
  final String category;
  final int maxParticipants;
  final int currentParticipants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.organizer,
    required this.category,
    required this.maxParticipants,
    required this.currentParticipants,
  });

  bool get isAvailable => currentParticipants < maxParticipants;
  
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String get participantsText {
    return '$currentParticipants/$maxParticipants participants';
  }
}