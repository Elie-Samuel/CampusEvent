import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/event_card.dart';
import '../widgets/logout_dialog.dart';
import '../../core/themes/app_theme.dart';
import '../../main.dart';
import '../../data/models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _dateFormat = 'dd/MM/yyyy';
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  void _refreshTheme() {
    _loadSettings();
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    switch (_dateFormat) {
      case 'MM/dd/yyyy':
        return '$month/$day/$year';
      case 'yyyy-MM-dd':
        return '$year-$month-$day';
      default:
        return '$day/$month/$year';
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
    final auth = context.watch<AuthViewModel>();
    final events = context.watch<EventViewModel>();
    final clubs = context.watch<ClubViewModel>();
    final notifications = context.watch<NotificationViewModel>();
    final user = auth.currentUser;

    if (user != null) {
      notifications.setCurrentUser(user.id);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myAppState = MyAppState.of(context);
      if (myAppState != null) {
        _loadSettings();
      }
    });

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      drawer: _buildDrawer(context, auth),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async {
            await Future.wait([
              events.loadUpcomingEvents(),
              notifications.loadNotifications(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: _getBackgroundColor(),
                pinned: true,
                elevation: 0,
                centerTitle: false,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: Icon(Icons.menu, color: _getTextColor()),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'CampusEvent',
                        style: TextStyle(
                          color: _getTextColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: _getTextColor()),
                        onPressed: () {
                          context.push('/notifications');
                        },
                      ),
                      if (notifications.unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              notifications.unreadCount > 99 
                                  ? '99+' 
                                  : '${notifications.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: _getTextColor()),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    const SizedBox(height: 4),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.event_available,
                          label: _getText('Événements\nà venir', 'Upcoming\nevents', 'Próximos\neventos'),
                          value: '${events.upcomingEvents.length}',
                          color: AppTheme.primaryColor,
                          isDarkMode: _isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.people_outline,
                          label: _getText('Clubs\ndisponibles', 'Available\nclubs', 'Clubes\ndisponibles'),
                          value: '${clubs.clubs.length}',
                          color: const Color(0xFF1E88E5),
                          isDarkMode: _isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.bookmark_outline,
                          label: _getText('Mes\ninscrip.', 'My\nregistrations', 'Mis\nregistros'),
                          value: '${events.userEvents.length}',
                          color: const Color(0xFF43A047),
                          isDarkMode: _isDarkMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _getText('Accès rapide', 'Quick access', 'Acceso rápido'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ✅ ROW DES ACCÈS RAPIDES - AVEC FILTRAGE PAR RÔLE
                    _buildQuickActions(auth),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getText('Événements à venir', 'Upcoming events', 'Próximos eventos'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/events'),
                          child: Text(
                            _getText('Voir tout', 'View all', 'Ver todo'),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (events.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      )
                    else if (events.upcomingEvents.isEmpty)
                      _EmptyState(
                        icon: Icons.event_busy_outlined,
                        message: _getText('Aucun événement à venir', 'No upcoming events', 'No hay próximos eventos'),
                        onAction: auth.canCreateEvent() 
                            ? () => _showCreateMenu(context, auth)
                            : null,
                        actionLabel: _getText('Créer', 'Create', 'Crear'),
                        isDarkMode: _isDarkMode,
                      )
                    else
                      ...events.upcomingEvents.take(4).map(
                            (e) => EventCard(
                              event: e,
                              userId: user?.id ?? '',
                              viewModel: events,
                              dateFormat: _dateFormat,
                              isDarkMode: _isDarkMode,
                            ),
                          ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      // ✅ FAB - UNIQUEMENT SI L'UTILISATEUR PEUT CRÉER QUELQUE CHOSE
      floatingActionButton: (auth.canCreateEvent() || auth.canCreateClub() || auth.canCreateConference())
          ? FloatingActionButton(
              onPressed: () => _showCreateMenu(context, auth),
              tooltip: _getText('Créer', 'Create', 'Crear'),
              backgroundColor: const Color(0xFF00897B),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // ✅ MÉTHODE POUR CONSTRUIRE LES ACCÈS RAPIDES SELON LE RÔLE
  Widget _buildQuickActions(AuthViewModel auth) {
    final List<Widget> actions = [];

    // 🔹 Événements - Visible par tous
    actions.add(
      _QuickAction(
        icon: Icons.event,
        label: _getText('Événements', 'Events', 'Eventos'),
        color: AppTheme.primaryColor,
        onTap: () => context.go('/events'),
        isDarkMode: _isDarkMode,
      ),
    );

    // 🔹 Clubs - Visible par tous
    actions.add(
      _QuickAction(
        icon: Icons.people,
        label: _getText('Clubs', 'Clubs', 'Clubes'),
        color: const Color(0xFF1E88E5),
        onTap: () => context.go('/clubs'),
        isDarkMode: _isDarkMode,
      ),
    );

    // 🔹 Conférences - Visible par tous
    actions.add(
      _QuickAction(
        icon: Icons.mic,
        label: _getText('Conférences', 'Conferences', 'Conferencias'),
        color: const Color(0xFF8E24AA),
        onTap: () => context.go('/conference'),
        isDarkMode: _isDarkMode,
      ),
    );

    // 🔹 Créer - UNIQUEMENT SI L'UTILISATEUR PEUT CRÉER
    // ✅ Correction : Vérifier explicitement les permissions de création
    final bool canCreate = auth.canCreateEvent() || auth.canCreateClub() || auth.canCreateConference();
    if (canCreate) {
      actions.add(
        _QuickAction(
          icon: Icons.add_circle_outline,
          label: _getText('Créer', 'Create', 'Crear'),
          color: const Color(0xFF00897B),
          onTap: () => _showCreateMenu(context, auth),
          isDarkMode: _isDarkMode,
        ),
      );
    }

    // 🔹 Administration - UNIQUEMENT POUR L'ADMIN
    if (auth.isAdmin) {
      actions.add(
        _QuickAction(
          icon: Icons.admin_panel_settings,
          label: _getText('Admin', 'Admin', 'Admin'),
          color: Colors.purple,
          onTap: () => context.push('/admin'),
          isDarkMode: _isDarkMode,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions,
    );
  }

  // lib/presentation/pages/home_page.dart - Partie modifiée

  // Méthode pour afficher le menu de création
  void _showCreateMenu(BuildContext context, AuthViewModel auth) {
    final List<Map<String, dynamic>> options = [];
    
    // 🔹 Événement - Disponible pour Admin, Organisateur et Chef de club
    if (auth.canCreateEvent()) {
      options.add({
        'label': _getText('Événement', 'Event', 'Evento'),
        'icon': Icons.event,
        'route': '/create-event',
        'color': AppTheme.primaryColor,
      });
    }
    
    // 🔹 Conférence - Disponible pour Admin, Organisateur et Chef de club
    if (auth.canCreateConference()) {
      options.add({
        'label': _getText('Conférence', 'Conference', 'Conferencia'),
        'icon': Icons.mic,
        'route': '/create-conference',
        'color': const Color(0xFF8E24AA),
      });
    }
    
    // 🔹 Club - Uniquement pour Admin
    if (auth.canCreateClub()) {
      options.add({
        'label': _getText('Club', 'Club', 'Club'),
        'icon': Icons.people,
        'route': '/create-club',
        'color': const Color(0xFF1E88E5),
      });
    }
    
    if (options.isEmpty) {
      // Aucune option disponible - ne rien faire
      return;
    }
    
    if (options.length == 1) {
      // Si une seule option, naviguer directement
      context.push(options[0]['route']);
      return;
    }
    
    // Afficher le menu avec plusieurs options
    showModalBottomSheet(
      context: context,
      backgroundColor: _getBackgroundColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _getMutedTextColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getText('Créer', 'Create', 'Crear'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            ...options.map((option) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (option['color'] as Color).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(option['icon'], color: option['color']),
              ),
              title: Text(
                option['label'],
                style: TextStyle(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: _getMutedTextColor()),
              onTap: () {
                Navigator.pop(context);
                context.push(option['route']);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthViewModel auth) {
    final user = auth.currentUser;
    final notificationViewModel = context.watch<NotificationViewModel>();
    
    return Drawer(
      backgroundColor: _getBackgroundColor(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: _getProfileImageWidget(user),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.fullName ?? _getText('Utilisateur', 'User', 'Usuario'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: _getText('Accueil', 'Home', 'Inicio'),
            onTap: () {
              context.go('/home');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.event_outlined,
            label: _getText('Événements', 'Events', 'Eventos'),
            onTap: () {
              context.go('/events');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.people_outline,
            label: _getText('Clubs', 'Clubs', 'Clubes'),
            onTap: () {
              context.go('/clubs');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.notifications_outlined,
            label: _getText('Notifications', 'Notifications', 'Notificaciones'),
            onTap: () {
              context.push('/notifications');
              Navigator.pop(context);
            },
            trailing: notificationViewModel.unreadCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${notificationViewModel.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.mic_outlined,
            label: _getText('Conférences', 'Conferences', 'Conferencias'),
            onTap: () {
              context.go('/conference');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: _getText('Paramètres', 'Settings', 'Ajustes'),
            onTap: () {
              context.push('/settings');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          // ✅ ADMINISTRATION - UNIQUEMENT POUR L'ADMIN
          if (auth.isAdmin)
            _DrawerItem(
              icon: Icons.admin_panel_settings,
              label: _getText('Administration', 'Administration', 'Administración'),
              color: Colors.purple,
              onTap: () {
                context.push('/admin');
                Navigator.pop(context);
              },
              isDarkMode: _isDarkMode,
            ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.person_outline,
            label: _getText('Mon profil', 'My profile', 'Mi perfil'),
            onTap: () {
              context.push('/profile');
              Navigator.pop(context);
            },
            isDarkMode: _isDarkMode,
          ),
          _DrawerItem(
            icon: Icons.logout,
            label: _getText('Déconnexion', 'Logout', 'Cerrar sesión'),
            color: AppTheme.errorColor,
            onTap: () => LogoutDialog.show(context, auth),
            isDarkMode: _isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _getProfileImageWidget(UserModel? user) {
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      final imageFile = File(user.profileImage!);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
        );
      }
    }
    
    return Icon(
      Icons.person,
      size: 32,
      color: AppTheme.primaryColor,
    );
  }
}

// ── Widgets locaux avec mode sombre ─────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCard : color.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkCard : color.withAlpha(18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? AppTheme.darkText : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Widget? trailing;
  final bool isDarkMode;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.black,
    this.trailing,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppTheme.darkText : color;
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool isDarkMode;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.onAction,
    this.actionLabel,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted.withAlpha(120),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}