import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Set<int> _sentNotificationIds = {};
  
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }
  
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (_sentNotificationIds.contains(id)) return;
    _sentNotificationIds.add(id);
    Future.delayed(const Duration(seconds: 10), () => _sentNotificationIds.remove(id));
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'campus_event_channel',
      'CampusEvent Notifications',
      channelDescription: 'Notifications pour les événements du campus',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(id, title, body, details, payload: payload);
  }
  
  Future<void> showRegistrationConfirmation({
    required String eventId,
    required String eventTitle,
  }) async {
    final id = 'reg_$eventId'.hashCode;
    await showNotification(
      id: id,
      title: 'Inscription confirmée !',
      body: 'Vous êtes inscrit à "$eventTitle"',
      payload: 'event_$eventId',
    );
  }
  
  Future<void> showRegistrationCancelled({
    required String eventId,
    required String eventTitle,
  }) async {
    final id = 'cancel_$eventId'.hashCode;
    await showNotification(
      id: id,
      title: 'Inscription annulée',
      body: 'Vous vous êtes désinscrit de "$eventTitle"',
      payload: 'event_$eventId',
    );
  }
}