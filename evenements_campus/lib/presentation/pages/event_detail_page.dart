import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import 'event_qr_page.dart';
import 'qr_scanner_page.dart';
import '../../core/themes/app_theme.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthViewModel>();
      if (auth.currentUser != null) {
        context.read<EventViewModel>().loadUserEvents(auth.currentUser!.id);
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
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.black87;
  }

  Color _getBorderColor() {
    return _isDarkMode ? AppTheme.darkBorder : const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventViewModel>();
    final auth = context.watch<AuthViewModel>();
    final uid = auth.currentUser?.id ?? '';
    Event? event = ev.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _getTextColor()),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            _getText('Événement introuvable', 'Event not found', 'Evento no encontrado'),
            style: TextStyle(color: _getTextColor()),
          ),
        ),
      );
    }

    final isRegistered = ev.isRegistered(widget.eventId);
    final isOrganizer = event.organizerId == uid;
    final isFull = event.isFull;
    final canEdit = auth.canEditEvent(event.organizerId);
    final canDelete = auth.canDeleteEvent(event.organizerId);

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
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
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code, color: AppTheme.primaryColor),
                tooltip: _getText('QR Code', 'QR Code', 'Código QR'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventQRPage(event: event!)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
                tooltip: _getText('Scanner QR', 'Scan QR', 'Escanear QR'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerPage()),
                ),
              ),
              if (canEdit || canDelete)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: _getTextColor()),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      if (event.type == EventType.conference) {
                        context.push('/edit-conference', extra: event);
                      } else {
                        context.push('/create-event', extra: event);
                      }
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
                        await ev.deleteEvent(event.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_getText('Événement supprimé avec succès', 'Event deleted successfully', 'Evento eliminado con éxito')),
                            ),
                          );
                          context.go('/events');
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                ),
                child: Center(
                  child: Icon(
                    event.type.icon,
                    size: 80,
                    color: AppTheme.primaryColor.withAlpha(180),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.type.label,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: event.formattedDate,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: event.formattedTimeRange,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: event.location,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.person_outline,
                  text: event.organizerName,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.people_outline,
                  text: event.participantsText,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 24),
                Divider(height: 1, color: _getBorderColor()),
                const SizedBox(height: 20),
                Text(
                  _getText('À propos', 'About', 'Acerca de'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: _getMutedTextColor(),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                if (isOrganizer && (canEdit || canDelete))
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/create-event', extra: event),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(_getText('Modifier', 'Edit', 'Editar')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
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
                              await ev.deleteEvent(event.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_getText('Événement supprimé avec succès', 'Event deleted successfully', 'Evento eliminado con éxito')),
                                  ),
                                );
                                context.go('/events');
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outlined),
                          label: Text(_getText('Supprimer', 'Delete', 'Eliminar')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else if (isFull && !isRegistered)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: (_isDarkMode ? AppTheme.darkCard : Colors.grey).withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _getText('Événement complet', 'Event full', 'Evento completo'),
                        style: TextStyle(
                          color: _isDarkMode ? AppTheme.darkTextMuted : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: ev.isLoading
                          ? null
                          : () async {
                              if (isRegistered) {
                                await ev.unregisterFromEvent(widget.eventId, uid);
                              } else {
                                await ev.registerForEvent(widget.eventId, uid);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isRegistered
                                          ? _getText('Inscription annulée', 'Registration cancelled', 'Inscripción cancelada')
                                          : _getText('Inscription confirmée !', 'Registration confirmed!', '¡Inscripción confirmada!'),
                                    ),
                                    backgroundColor: isRegistered
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        isRegistered
                            ? Icons.cancel_outlined
                            : Icons.check_circle_outline,
                      ),
                      label: Text(
                        isRegistered
                            ? _getText("Annuler l'inscription", 'Cancel registration', 'Cancelar inscripción')
                            : _getText("S'inscrire", 'Register', 'Inscribirse'),
                      ),
                      style: isRegistered
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            )
                          : ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDarkMode;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkText : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}