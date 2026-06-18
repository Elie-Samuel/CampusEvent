import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/club.dart';
import '../../core/themes/app_theme.dart';
import '../viewmodels/club_viewmodel.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final bool canEdit;
  final bool isDarkMode;

  const ClubCard({
    super.key, 
    required this.club,
    this.canEdit = false,
    this.isDarkMode = false,
  });

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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('/club/${club.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people,
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _getMutedTextColor()),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${club.memberCount} membres',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getMutedTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: _getMutedTextColor()),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/edit-club', extra: club);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: _getCardColor(),
                          title: Text('Supprimer le club', style: TextStyle(color: _getTextColor())),
                          content: Text('Voulez-vous vraiment supprimer ce club ?', style: TextStyle(color: _getTextColor())),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Annuler', style: TextStyle(color: _getMutedTextColor())),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final clubViewModel = Provider.of<ClubViewModel>(context, listen: false);
                        await clubViewModel.deleteClub(club.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Club supprimé avec succès')),
                          );
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
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
        ),
      ),
    );
  }
}