import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class ConferencePage extends StatefulWidget {
  const ConferencePage({super.key});

  @override
  State<ConferencePage> createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {
  bool _isDarkMode = false;
  String _dateFormat = 'dd/MM/yyyy';
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
      _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
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

  Color _getTextColor() {
    return _isDarkMode ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
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

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventViewModel>();
    final auth = context.watch<AuthViewModel>();
    final uid = auth.currentUser?.id ?? '';

    // Filtrer les conférences
    final conferences = ev.upcomingEvents
        .where((e) => e.type == EventType.conference)
        .toList();

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        title: Text(
          _getText('Conférences', 'Conferences', 'Conferencias'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (auth.canCreateConference())
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              onPressed: () => context.push('/create-conference'),
              tooltip: _getText('Créer une conférence', 'Create conference', 'Crear conferencia'),
            ),
        ],
      ),
      body: ev.isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : conferences.isEmpty
              ? _buildEmptyState(context, auth)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: conferences.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _buildConferenceCard(
                    context,
                    conferences[index],
                    uid,
                    ev,
                    auth,
                  ),
                ),
    );
  }

  Widget _buildConferenceCard(
    BuildContext context,
    Event conference,
    String userId,
    EventViewModel viewModel,
    AuthViewModel auth,
  ) {
    final isRegistered = viewModel.isRegistered(conference.id);
    final isFull = conference.isFull;
    final isOrganizer = conference.organizerId == userId;
    final canEdit = auth.canEditEvent(conference.organizerId);
    final canDelete = auth.canDeleteEvent(conference.organizerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: _isDarkMode ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/event/${conference.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          conference.type.icon,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          conference.type.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isRegistered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getText('Inscrit', 'Registered', 'Inscrito'),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (canEdit || canDelete)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: _getMutedTextColor()),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          context.push('/edit-conference', extra: conference);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: _isDarkMode ? AppTheme.darkCard : Colors.white,
                              title: Text(_getText('Supprimer', 'Delete', 'Eliminar'), style: TextStyle(color: _getTextColor())),
                              content: Text(
                                _getText('Voulez-vous vraiment supprimer cette conférence ?', 'Do you really want to delete this conference?', '¿Realmente quieres eliminar esta conferencia?'),
                                style: TextStyle(color: _getTextColor()),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(_getText('Annuler', 'Cancel', 'Cancelar'), style: TextStyle(color: _getMutedTextColor())),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(_getText('Supprimer', 'Delete', 'Eliminar'), style: const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await viewModel.deleteEvent(conference.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getText('Conférence supprimée avec succès', 'Conference deleted successfully', 'Conferencia eliminada con éxito')),
                                ),
                              );
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
                                Text(_getText('Modifier', 'Edit', 'Editar'), style: TextStyle(color: _getTextColor())),
                              ],
                            ),
                          ),
                        if (canDelete)
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 18, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(_getText('Supprimer', 'Delete', 'Eliminar'), style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conference.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _getMutedTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(conference.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getMutedTextColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: _getMutedTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      conference.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getMutedTextColor(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: _getMutedTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: conference.participationRate,
                      backgroundColor: Colors.grey.shade200,
                      color: conference.isFull ? Colors.red : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${conference.currentParticipants}/${conference.maxParticipants}',
                    style: TextStyle(
                      fontSize: 12,
                      color: conference.isFull ? Colors.red : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFull && !isRegistered
                      ? null
                      : () async {
                          if (isRegistered) {
                            await viewModel.unregisterFromEvent(conference.id, userId);
                          } else {
                            await viewModel.registerForEvent(conference.id, userId);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isRegistered
                                      ? _getText('Inscription annulée', 'Registration cancelled', 'Inscripción cancelada')
                                      : _getText('Inscription confirmée !', 'Registration confirmed!', '¡Inscripción confirmada!'),
                                ),
                                backgroundColor:
                                    isRegistered ? Colors.red : Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRegistered ? Colors.red : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isRegistered
                        ? _getText("Annuler l'inscription", 'Cancel registration', 'Cancelar inscripción')
                        : (isFull 
                            ? _getText('Complet', 'Full', 'Completo') 
                            : _getText("S'inscrire", 'Register', 'Inscribirse')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AuthViewModel auth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_none,
              size: 64,
              color: _getMutedTextColor().withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              _getText('Aucune conférence disponible', 'No conferences available', 'No hay conferencias disponibles'),
              style: TextStyle(color: _getMutedTextColor(), fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (auth.canCreateConference())
              ElevatedButton.icon(
                onPressed: () => context.push('/create-conference'),
                icon: const Icon(Icons.add),
                label: Text(_getText('Créer une conférence', 'Create conference', 'Crear conferencia')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}