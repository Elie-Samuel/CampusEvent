class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final DateTime createdAt;
  final bool isRead;
  final String? imageUrl;
  
  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
    this.imageUrl,
  });
  
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: map['title'].toString(),
      body: map['body'].toString(),
      type: map['type'].toString(),
      relatedId: map['related_id']?.toString(),
      createdAt: DateTime.parse(map['created_at'].toString()),
      isRead: map['is_read'] == 1,
      imageUrl: map['image_url']?.toString(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      'image_url': imageUrl,
    };
  }
}