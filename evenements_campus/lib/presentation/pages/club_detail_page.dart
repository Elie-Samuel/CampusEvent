import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/club.dart';
import '../../core/themes/app_theme.dart';

class ClubDetailPage extends StatefulWidget {
  final String clubId;
  const ClubDetailPage({super.key, required this.clubId});

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthViewModel>();
      final uid = auth.currentUser?.id ?? '';
      if (uid.isNotEmpty) {
        context.read<ClubViewModel>().loadUserClubs(uid);
        context.read<ClubViewModel>().loadClubs();
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
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.grey;
  }

  Color _getBorderColor() {
    return _isDarkMode ? AppTheme.darkBorder : const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClubViewModel>();
    final auth = context.watch<AuthViewModel>();
    final uid = auth.currentUser?.id ?? '';
    final userName = auth.currentUser?.fullName ?? '';

    Club club;
    try {
      club = vm.clubs.firstWhere((c) => c.id == widget.clubId);
    } catch (e) {
      club = Club(
        id: '',
        name: _getText('Club introuvable', 'Club not found', 'Club no encontrado'),
        description: '',
        category: '',
        presidentId: '',
        presidentName: '',
        memberCount: 0,
      );
    }

    if (club.id.isEmpty) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getCardColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: _getTextColor(), size: 18),
            ),
            onPressed: () => context.go('/clubs'),
          ),
        ),
        body: Center(
          child: Text(
            _getText('Club introuvable', 'Club not found', 'Club no encontrado'),
            style: TextStyle(color: _getTextColor()),
          ),
        ),
      );
    }

    final isMember = vm.isJoined(widget.clubId);
    final isLeader = club.presidentId == uid;
    final canEdit = auth.canEditClub(club.presidentId);
    final canDelete = auth.canDeleteClub(club.presidentId);

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getBackgroundColor(),
            foregroundColor: _getTextColor(),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getCardColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: _getTextColor(), size: 18),
              ),
              onPressed: () => context.go('/clubs'),
            ),
            actions: [
              if (canEdit || canDelete)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: _getTextColor()),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/edit-club', extra: club);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
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
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                _getText('Annuler', 'Cancel', 'Cancelar'),
                                style: TextStyle(color: _getMutedTextColor()),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                _getText('Supprimer', 'Delete', 'Eliminar'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await vm.deleteClub(club.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getText('Club supprimé avec succès', 'Club deleted successfully', 'Club eliminado con éxito')),
                            ),
                          );
                          context.go('/clubs');
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    if (canEdit)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: _getTextColor()),
                            const SizedBox(width: 8),
                            Text(
                              _getText('Modifier', 'Edit', 'Editar'),
                              style: TextStyle(color: _getTextColor()),
                            ),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _getCardColor(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.people,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (club.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      club.category,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                Text(
                  club.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: _getMutedTextColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getText('${club.memberCount} membres', '${club.memberCount} members', '${club.memberCount} miembros'),
                      style: TextStyle(
                        color: _getMutedTextColor(),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: _getBorderColor()),
                const SizedBox(height: 20),

                Text(
                  _getText('À propos du club', 'About the club', 'Acerca del club'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  club.description.isNotEmpty
                      ? club.description
                      : _getText('Aucune description disponible.', 'No description available.', 'No hay descripción disponible.'),
                  style: TextStyle(
                    fontSize: 15,
                    color: _getTextColor().withOpacity(0.87),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                if (isLeader)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryColor.withAlpha(60),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getText('Vous êtes le responsable de ce club', 'You are the leader of this club', 'Eres el responsable de este club'),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (isMember) {
                                await vm.leaveClub(widget.clubId, uid);
                              } else {
                                await vm.joinClub(widget.clubId, uid, userName);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isMember
                                          ? _getText('Vous avez quitté le club', 'You left the club', 'Has salido del club')
                                          : _getText('Vous avez rejoint le club !', 'You joined the club!', '¡Te has unido al club!'),
                                    ),
                                    backgroundColor: isMember
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        isMember
                            ? Icons.exit_to_app_outlined
                            : Icons.group_add_outlined,
                      ),
                      label: Text(
                        isMember
                            ? _getText('Quitter le club', 'Leave club', 'Salir del club')
                            : _getText('Rejoindre le club', 'Join club', 'Unirse al club'),
                      ),
                      style: isMember
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            )
                          : ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}