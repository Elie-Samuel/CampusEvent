import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/local/app_database.dart';
import '../../domain/entities/notification.dart';
import '../../services/notification_service.dart';
import '../../core/constants/app_constants.dart';

class NotificationViewModel extends ChangeNotifier {
  final AppDatabase _database;
  final NotificationService _notificationService = NotificationService();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;
  String? _currentUserId;
  
  // Timer pour rafraîchissement automatique
  Timer? _autoRefreshTimer;
  
  NotificationViewModel(this._database) {
    // Ne pas démarrer le timer automatiquement pour éviter les appels inutiles
    // Le timer sera démarré quand un utilisateur est connecté
  }
  
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentUserId != null && _currentUserId!.isNotEmpty) {
        print('Auto-refresh des notifications...');
        loadNotifications();
      }
    });
  }
  
  void setCurrentUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _startAutoRefresh(); // Démarrer le rafraîchissement auto
      loadNotifications();
    }
  }
  
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  
  Future<void> loadNotifications() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    try {
      final db = await _database.database;
      final results = await db.query(
        AppConstants.tableNotifications,
        where: 'user_id = ?',
        whereArgs: [_currentUserId],
        orderBy: 'created_at DESC',
      );
      
      final oldCount = _unreadCount;
      _notifications = results.map((e) => AppNotification.fromMap(e)).toList();
      _updateUnreadCount();
      
      // Notifier seulement si le compteur a changé
      if (oldCount != _unreadCount) {
        print('[DEBUG] Notifications mises à jour: $_unreadCount non lues');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addNotification(AppNotification notification) async {
    try {
      final db = await _database.database;
      
      print('[DEBUG] Ajout notification pour user: ${notification.userId}');
      
      final existing = await db.query(
        AppConstants.tableNotifications,
        where: 'user_id = ? AND related_id = ? AND type = ? AND is_read = 0',
        whereArgs: [notification.userId, notification.relatedId, notification.type],
      );
      
      if (existing.isNotEmpty) {
        print('Notification déjà existante, ignore');
        return;
      }
      
      await db.insert(
        AppConstants.tableNotifications,
        notification.toMap(),
      );
      
      print('Notification ajoutée avec succès');
      
      if (notification.userId == _currentUserId) {
        await loadNotifications();
      }
      
      await _notificationService.showNotification(
        id: notification.id.hashCode,
        title: notification.title,
        body: notification.body,
        payload: notification.relatedId,
      );
    } catch (e) {
      print('Error adding notification: $e');
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      final db = await _database.database;
      await db.update(
        AppConstants.tableNotifications,
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      await loadNotifications();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    
    try {
      final db = await _database.database;
      await db.update(
        AppConstants.tableNotifications,
        {'is_read': 1},
        where: 'user_id = ? AND is_read = 0',
        whereArgs: [_currentUserId],
      );
      await loadNotifications();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      final db = await _database.database;
      await db.delete(
        AppConstants.tableNotifications,
        where: 'id = ?',
        whereArgs: [notificationId],
      );
      await loadNotifications();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;
    
    try {
      final db = await _database.database;
      await db.delete(
        AppConstants.tableNotifications,
        where: 'user_id = ?',
        whereArgs: [_currentUserId],
      );
      await loadNotifications();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }
  
  void _updateUnreadCount() {
    final newCount = _notifications.where((n) => !n.isRead).length;
    if (_unreadCount != newCount) {
      _unreadCount = newCount;
      print('[DEBUG] Unread count mis à jour: $_unreadCount');
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clear() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    _notifications = [];
    _unreadCount = 0;
    _currentUserId = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}