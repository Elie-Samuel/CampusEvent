import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
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
    return _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;
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
    final auth = context.watch<AuthViewModel>();
    final viewModel = context.watch<EventViewModel>();

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Événements', 'Events', 'Eventos'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (auth.canCreateEvent())
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              onPressed: () => context.push('/create-event'),
              tooltip: _getText('Créer un événement', 'Create event', 'Crear evento'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
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
                fillColor: _isDarkMode ? AppTheme.darkCard : Colors.grey.shade100,
              ),
              onChanged: (query) => viewModel.setSearchQuery(query),
            ),
          ),
          // Filtres par type
          _buildFilterChips(context, viewModel),
          // Liste des événements
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.filteredEvents.isEmpty
                    ? Center(
                        child: Text(
                          _getText('Aucun événement trouvé', 'No events found', 'No se encontraron eventos'),
                          style: TextStyle(color: _getMutedTextColor()),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: viewModel.filteredEvents.length,
                        itemBuilder: (context, index) => _buildEventCard(
                          context,
                          viewModel.filteredEvents[index],
                          auth,
                          viewModel,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, EventViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(_getText('Tous', 'All', 'Todos'), style: TextStyle(color: _getTextColor())),
            selected: viewModel.selectedType == null,
            onSelected: (_) => viewModel.filterByType(null),
            selectedColor: AppTheme.primaryColor.withAlpha(30),
            checkmarkColor: AppTheme.primaryColor,
            backgroundColor: _getCardColor(),
          ),
          const SizedBox(width: 8),
          ...EventType.values.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.label, style: TextStyle(color: _getTextColor())),
              selected: viewModel.selectedType == type,
              onSelected: (_) => viewModel.filterByType(type),
              selectedColor: AppTheme.primaryColor.withAlpha(30),
              checkmarkColor: AppTheme.primaryColor,
              backgroundColor: _getCardColor(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    Event event,
    AuthViewModel auth,
    EventViewModel viewModel,
  ) {
    final isOrganizer = event.organizerId == auth.currentUser?.id;
    final canEdit = auth.canEditEvent(event.organizerId);
    final canDelete = auth.canDeleteEvent(event.organizerId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/event/${event.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.type.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isOrganizer && (canEdit || canDelete))
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: _getMutedTextColor()),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          context.push('/create-event', extra: event);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: _getCardColor(),
                              title: Text(
                                _getText('Supprimer', 'Delete', 'Eliminar'),
                                style: TextStyle(color: _getTextColor()),
                              ),
                              content: Text(
                                _getText('Voulez-vous vraiment supprimer cet événement ?', 'Do you really want to delete this event?', '¿Realmente quieres eliminar este evento?'),
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
                            await viewModel.deleteEvent(event.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getText('Événement supprimé', 'Event deleted', 'Evento eliminado')),
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
                                Text(
                                  _getText('Modifier', 'Edit', 'Editar'),
                                  style: TextStyle(color: _getTextColor()),
                                ),
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
                                Text(
                                  _getText('Supprimer', 'Delete', 'Eliminar'),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
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
                  Icon(Icons.calendar_today_outlined, size: 14, color: _getMutedTextColor()),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(event.date),
                    style: TextStyle(fontSize: 12, color: _getMutedTextColor()),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.location_on_outlined, size: 14, color: _getMutedTextColor()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(fontSize: 12, color: _getMutedTextColor()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 14, color: _getMutedTextColor()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: event.participationRate,
                      backgroundColor: _isDarkMode ? AppTheme.darkBorder : Colors.grey.shade200,
                      color: event.isFull ? Colors.red : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants}',
                    style: TextStyle(
                      fontSize: 12,
                      color: event.isFull ? Colors.red : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}