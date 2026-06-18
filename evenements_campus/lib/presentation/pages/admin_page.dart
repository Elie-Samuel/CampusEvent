// lib/presentation/pages/admin_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/club_viewmodel.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/club.dart';
import '../../data/models/user_model.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedTab = 0;
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadData();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  void _loadData() {
    final auth = context.read<AuthViewModel>();
    final events = context.read<EventViewModel>();
    final clubs = context.read<ClubViewModel>();
    
    auth.getAllUsers();
    events.getAllEvents();
    clubs.getAllClubs();
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en': return en;
      case 'es': return es;
      default: return fr;
    }
  }

  Color _getBackgroundColor() => _isDarkMode ? AppTheme.darkBackground : Colors.white;
  Color _getCardColor() => _isDarkMode ? AppTheme.darkCard : Colors.white;
  Color _getTextColor() => _isDarkMode ? AppTheme.darkText : Colors.black;
  Color _getMutedTextColor() => _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  Color _getBorderColor() => _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    
    if (!auth.isAdmin) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          title: Text(
            _getText('Accès refusé', 'Access denied', 'Acceso denegado'),
            style: TextStyle(color: _getTextColor()),
          ),
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _getTextColor()),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 80, color: Colors.red.withAlpha(100)),
              const SizedBox(height: 16),
              Text(
                _getText('Vous n\'avez pas les droits d\'administration', 'You do not have admin rights', 'No tienes derechos de administrador'),
                style: TextStyle(fontSize: 16, color: _getMutedTextColor()),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(_getText('Retour', 'Back', 'Volver')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Administration', 'Administration', 'Administración'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _getTextColor()),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getText('Données actualisées', 'Data refreshed', 'Datos actualizados')),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                _UsersTab(),
                _EventsTab(),
                _ClubsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      _getText('Utilisateurs', 'Users', 'Usuarios'),
      _getText('Événements', 'Events', 'Eventos'),
      _getText('Clubs', 'Clubs', 'Clubes'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _getMutedTextColor(),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── TAB UTILISATEURS ─────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  String _searchQuery = '';
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
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en': return en;
      case 'es': return es;
      default: return fr;
    }
  }

  Color _getCardColor() => _isDarkMode ? AppTheme.darkCard : Colors.white;
  Color _getTextColor() => _isDarkMode ? AppTheme.darkText : Colors.black;
  Color _getMutedTextColor() => _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  Color _getBorderColor() => _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final allUsers = auth.allUsers;
    
    final filteredUsers = allUsers.where((u) {
      final query = _searchQuery.toLowerCase();
      return u.fullName.toLowerCase().contains(query) ||
             u.email.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: _getTextColor()),
            decoration: InputDecoration(
              hintText: _getText('Rechercher un utilisateur...', 'Search users...', 'Buscar usuarios...'),
              hintStyle: TextStyle(color: _getMutedTextColor()),
              prefixIcon: Icon(Icons.search, color: _getMutedTextColor()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _getCardColor(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: auth.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        _getText('Aucun utilisateur trouvé', 'No users found', 'No se encontraron usuarios'),
                        style: TextStyle(color: _getMutedTextColor()),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isCurrentUser = auth.currentUser?.id == user.id;
                        final isAdminUser = user.email == 'admin@gmail.com';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: _getCardColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _getBorderColor()),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRoleColor(user.role).withAlpha(20),
                              child: Text(
                                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                style: TextStyle(color: _getRoleColor(user.role)),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              user.email,
                              style: TextStyle(color: _getMutedTextColor(), fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✅ Badge "Vous" pour l'utilisateur actuel
                                if (isCurrentUser)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getText('Vous', 'You', 'Tú'),
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (isCurrentUser) const SizedBox(width: 4),
                                
                                // ✅ Badge de rôle
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role).withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getRoleLabel(user.role),
                                    style: TextStyle(
                                      color: _getRoleColor(user.role),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                
                                // ✅ Bouton Supprimer (uniquement si l'admin peut supprimer)
                                if (auth.canDeleteUser(user.id) && !isCurrentUser && !isAdminUser)
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _showDeleteUserDialog(context, user, auth),
                                    tooltip: _getText('Supprimer', 'Delete', 'Eliminar'),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ✅ Dialogue de confirmation pour supprimer un utilisateur
  void _showDeleteUserDialog(BuildContext context, UserModel user, AuthViewModel auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(
          _getText('Supprimer l\'utilisateur', 'Delete user', 'Eliminar usuario'),
          style: TextStyle(color: _getTextColor()),
        ),
        content: Text(
          _getText(
            'Voulez-vous vraiment supprimer ${user.fullName} ?',
            'Do you really want to delete ${user.fullName}?',
            '¿Realmente quieres eliminar a ${user.fullName}?',
          ),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getText('Annuler', 'Cancel', 'Cancelar'),
              style: TextStyle(color: _getMutedTextColor()),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await auth.deleteUser(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? _getText('Utilisateur supprimé', 'User deleted', 'Usuario eliminado')
                          : _getText('Erreur lors de la suppression', 'Error deleting user', 'Error al eliminar'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(
              _getText('Supprimer', 'Delete', 'Eliminar'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin': return _getText('Admin', 'Admin', 'Admin');
      case 'organizer': return _getText('Organisateur', 'Organizer', 'Organizador');
      case 'club_president': return _getText('Chef de club', 'Club president', 'Presidente');
      default: return _getText('Étudiant', 'Student', 'Estudiante');
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'organizer': return Colors.blue;
      case 'club_president': return Colors.green;
      default: return AppTheme.primaryColor;
    }
  }
}

// ─── TAB ÉVÉNEMENTS ──────────────────────────────────────────────

class _EventsTab extends StatefulWidget {
  const _EventsTab();

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  String _searchQuery = '';
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
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en': return en;
      case 'es': return es;
      default: return fr;
    }
  }

  Color _getCardColor() => _isDarkMode ? AppTheme.darkCard : Colors.white;
  Color _getTextColor() => _isDarkMode ? AppTheme.darkText : Colors.black;
  Color _getMutedTextColor() => _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  Color _getBorderColor() => _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventViewModel>();
    final allEvents = events.allEvents;
    
    final filteredEvents = allEvents.where((e) {
      final query = _searchQuery.toLowerCase();
      return e.title.toLowerCase().contains(query) ||
             e.location.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: _getTextColor()),
            decoration: InputDecoration(
              hintText: _getText('Rechercher un événement...', 'Search events...', 'Buscar eventos...'),
              hintStyle: TextStyle(color: _getMutedTextColor()),
              prefixIcon: Icon(Icons.search, color: _getMutedTextColor()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _getCardColor(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: events.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredEvents.isEmpty
                  ? Center(
                      child: Text(
                        _getText('Aucun événement trouvé', 'No events found', 'No se encontraron eventos'),
                        style: TextStyle(color: _getMutedTextColor()),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: _getCardColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _getBorderColor()),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(event.type.icon, color: AppTheme.primaryColor, size: 20),
                            ),
                            title: Text(
                              event.title,
                              style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${event.location} • ${event.currentParticipants}/${event.maxParticipants}',
                              style: TextStyle(color: _getMutedTextColor(), fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                                  onPressed: () {
                                    if (event.type == EventType.conference) {
                                      context.push('/edit-conference', extra: event);
                                    } else {
                                      context.push('/create-event', extra: event);
                                    }
                                  },
                                  tooltip: _getText('Modifier', 'Edit', 'Editar'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteDialog(context, event),
                                  tooltip: _getText('Supprimer', 'Delete', 'Eliminar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(
          _getText('Supprimer l\'événement', 'Delete event', 'Eliminar evento'),
          style: TextStyle(color: _getTextColor()),
        ),
        content: Text(
          _getText('Voulez-vous vraiment supprimer cet événement ?', 'Do you really want to delete this event?', '¿Realmente quieres eliminar este evento?'),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getText('Annuler', 'Cancel', 'Cancelar'),
              style: TextStyle(color: _getMutedTextColor()),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final viewModel = context.read<EventViewModel>();
              await viewModel.deleteEvent(event.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_getText('Événement supprimé', 'Event deleted', 'Evento eliminado')),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              _getText('Supprimer', 'Delete', 'Eliminar'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB CLUBS ────────────────────────────────────────────────────

class _ClubsTab extends StatefulWidget {
  const _ClubsTab();

  @override
  State<_ClubsTab> createState() => _ClubsTabState();
}

class _ClubsTabState extends State<_ClubsTab> {
  String _searchQuery = '';
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
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  String _getText(String fr, String en, String es) {
    switch (_languageCode) {
      case 'en': return en;
      case 'es': return es;
      default: return fr;
    }
  }

  Color _getCardColor() => _isDarkMode ? AppTheme.darkCard : Colors.white;
  Color _getTextColor() => _isDarkMode ? AppTheme.darkText : Colors.black;
  Color _getMutedTextColor() => _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  Color _getBorderColor() => _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;

  @override
  Widget build(BuildContext context) {
    final clubs = context.watch<ClubViewModel>();
    final allClubs = clubs.allClubs;
    
    final filteredClubs = allClubs.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
             c.category.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: _getTextColor()),
            decoration: InputDecoration(
              hintText: _getText('Rechercher un club...', 'Search clubs...', 'Buscar clubes...'),
              hintStyle: TextStyle(color: _getMutedTextColor()),
              prefixIcon: Icon(Icons.search, color: _getMutedTextColor()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _getCardColor(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: clubs.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredClubs.isEmpty
                  ? Center(
                      child: Text(
                        _getText('Aucun club trouvé', 'No clubs found', 'No se encontraron clubes'),
                        style: TextStyle(color: _getMutedTextColor()),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = filteredClubs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: _getCardColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _getBorderColor()),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.people, color: AppTheme.primaryColor, size: 20),
                            ),
                            title: Text(
                              club.name,
                              style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${club.category} • ${club.memberCount} ${_getText('membres', 'members', 'miembros')}',
                              style: TextStyle(color: _getMutedTextColor(), fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                                  onPressed: () => context.push('/edit-club', extra: club),
                                  tooltip: _getText('Modifier', 'Edit', 'Editar'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _showDeleteDialog(context, club),
                                  tooltip: _getText('Supprimer', 'Delete', 'Eliminar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(
          _getText('Supprimer le club', 'Delete club', 'Eliminar club'),
          style: TextStyle(color: _getTextColor()),
        ),
        content: Text(
          _getText('Voulez-vous vraiment supprimer ce club ?', 'Do you really want to delete this club?', '¿Realmente quieres eliminar este club?'),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getText('Annuler', 'Cancel', 'Cancelar'),
              style: TextStyle(color: _getMutedTextColor()),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final viewModel = context.read<ClubViewModel>();
              await viewModel.deleteClub(club.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_getText('Club supprimé', 'Club deleted', 'Club eliminado')),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              _getText('Supprimer', 'Delete', 'Eliminar'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}