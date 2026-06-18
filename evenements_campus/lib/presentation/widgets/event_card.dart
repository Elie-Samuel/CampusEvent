import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final String userId;
  final dynamic viewModel;
  final String dateFormat;
  final bool isDarkMode;

  const EventCard({
    super.key,
    required this.event,
    required this.userId,
    required this.viewModel,
    this.dateFormat = 'dd/MM/yyyy',
    this.isDarkMode = false,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String _dateFormat = 'dd/MM/yyyy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
    });
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

  Color _getTextColor() {
    return widget.isDarkMode ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return widget.isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  }

  Color _getCardBackgroundColor() {
    return widget.isDarkMode ? AppTheme.darkCard : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isRegistered = widget.viewModel.isRegistered(widget.event.id);
    final isFull = widget.event.isFull;
    final canEdit = widget.viewModel.canEditEvent(widget.event.organizerId);
    final canDelete = widget.viewModel.canDeleteEvent(widget.event.organizerId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: _getCardBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/event/${widget.event.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge et menu action
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
                          widget.event.type.icon,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.event.type.label,
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Inscrit',
                            style: TextStyle(
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
                      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          context.push('/create-event', extra: widget.event);
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Supprimer'),
                              content: const Text('Voulez-vous vraiment supprimer cet événement ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await widget.viewModel.deleteEvent(widget.event.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Événement supprimé')),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        if (canEdit)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Modifier'),
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
              ),
              const SizedBox(height: 12),
              // Titre - CORRECTION : couleur adaptée au mode
              Text(
                widget.event.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(), // Utilise la couleur adaptée
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Date et lieu
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _getMutedTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.event.date),
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
                      widget.event.location,
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
              // Participants
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
                      value: widget.event.participationRate,
                      backgroundColor: Colors.grey.shade200,
                      color: widget.event.isFull ? Colors.red : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.event.currentParticipants}/${widget.event.maxParticipants}',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.event.isFull ? Colors.red : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bouton d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFull && !isRegistered
                      ? null
                      : () async {
                          if (isRegistered) {
                            await widget.viewModel.unregisterFromEvent(widget.event.id, widget.userId);
                          } else {
                            await widget.viewModel.registerForEvent(widget.event.id, widget.userId);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isRegistered
                                      ? 'Inscription annulée'
                                      : 'Inscription confirmée !',
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
                        ? 'Annuler l\'inscription'
                        : (isFull ? 'Complet' : 'S\'inscrire'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}