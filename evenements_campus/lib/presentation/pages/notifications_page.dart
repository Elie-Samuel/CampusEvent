import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/notification.dart';
import '../../core/themes/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Charger les notifications pour l'utilisateur connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthViewModel>();
      final notificationViewModel = context.read<NotificationViewModel>();
      if (auth.currentUser != null) {
        notificationViewModel.setCurrentUser(auth.currentUser!.id);
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return fr;
    }
  }

  Color _getBackgroundColor() {
    return _isDarkMode ? AppTheme.darkBackground : Colors.white;
  }

  Color _getCardColor() {
    return _isDarkMode ? AppTheme.darkCard : Colors.white;
  }

  Color _getTextColor() {
    return _isDarkMode ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final auth = context.watch<AuthViewModel>();

    // Si pas d'utilisateur connecté, rediriger vers login
    if (auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        title: Text(
          _getText('Notifications', 'Notifications', 'Notificaciones'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (viewModel.unreadCount > 0)
            TextButton(
              onPressed: () => viewModel.markAllAsRead(),
              child: Text(_getText('Tout lire', 'Mark all read', 'Marcar todo como leído'), style: TextStyle(color: AppTheme.primaryColor)),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: _getTextColor()),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog(context, viewModel);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_all', 
                child: Text(_getText('Supprimer toutes', 'Delete all', 'Eliminar todas'), style: TextStyle(color: _getTextColor())),
              ),
            ],
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => viewModel.loadNotifications(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: viewModel.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = viewModel.notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => _handleNotificationTap(context, notification, viewModel),
                        onDismissed: () => viewModel.deleteNotification(notification.id),
                        isDarkMode: _isDarkMode,
                        languageCode: _languageCode,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: _getMutedTextColor()),
          const SizedBox(height: 16),
          Text(
            _getText('Aucune notification', 'No notifications', 'Sin notificaciones'),
            style: TextStyle(fontSize: 18, color: _getMutedTextColor(), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('Les notifications apparaîtront ici', 'Notifications will appear here', 'Las notificaciones aparecerán aquí'),
            style: TextStyle(color: _getMutedTextColor()),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
    NotificationViewModel viewModel,
  ) {
    if (!notification.isRead) {
      viewModel.markAsRead(notification.id);
    }

    if (notification.relatedId != null && notification.relatedId!.isNotEmpty) {
      context.push('/event/${notification.relatedId}');
    }
  }

  void _showDeleteAllDialog(BuildContext context, NotificationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(_getText('Supprimer toutes', 'Delete all', 'Eliminar todas'), style: TextStyle(color: _getTextColor())),
        content: Text(
          _getText('Êtes-vous sûr de vouloir supprimer toutes les notifications ?', 'Are you sure you want to delete all notifications?', '¿Estás seguro de que quieres eliminar todas las notificaciones?'),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('Annuler', 'Cancel', 'Cancelar'), style: TextStyle(color: _getMutedTextColor())),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteAllNotifications();
            },
            child: Text(_getText('Supprimer', 'Delete', 'Eliminar'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final bool isDarkMode;
  final String languageCode;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
    required this.isDarkMode,
    required this.languageCode,
  });

  String _getText(String fr, String en, String es) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return fr;
    }
  }

  Color _getBackgroundColor() {
    return isDarkMode ? AppTheme.darkBackground : Colors.white;
  }

  Color _getCardColor() {
    return isDarkMode ? AppTheme.darkCard : Colors.white;
  }

  Color _getTextColor() {
    return isDarkMode ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return isDarkMode ? AppTheme.darkTextMuted : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead 
            ? _getCardColor() 
            : (isDarkMode ? AppTheme.darkCard.withAlpha(200) : Colors.blue.shade50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: !notification.isRead 
              ? BorderSide(color: AppTheme.primaryColor, width: 1) 
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14,
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(fontSize: 12, color: _getMutedTextColor()),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRelativeTime(notification.createdAt),
                        style: TextStyle(fontSize: 10, color: _getMutedTextColor()),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'registration_confirmation': return Icons.check_circle;
      case 'registration_cancelled': return Icons.cancel;
      case 'event_reminder': return Icons.alarm;
      case 'event_update': return Icons.edit;
      case 'welcome': return Icons.waving_hand;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'registration_confirmation': return Colors.green;
      case 'registration_cancelled': return Colors.red;
      case 'event_reminder': return Colors.orange;
      case 'event_update': return Colors.blue;
      case 'welcome': return AppTheme.primaryColor;
      default: return isDarkMode ? AppTheme.darkTextMuted : Colors.grey;
    }
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (difference.inDays > 0) {
      return _getText(
        'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}',
        '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago',
        'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}',
      );
    }
    if (difference.inHours > 0) {
      return _getText(
        'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}',
        '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago',
        'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}',
      );
    }
    if (difference.inMinutes > 0) {
      return _getText(
        'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}',
        '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago',
        'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}',
      );
    }
    return _getText('à l\'instant', 'just now', 'justo ahora');
  }
}