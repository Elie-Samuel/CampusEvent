import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/themes/app_theme.dart';

class ClubDetailsPage extends StatefulWidget {
  final String clubId;

  const ClubDetailsPage({super.key, required this.clubId});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
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
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClubViewModel>();
    final club = viewModel.getClubById(widget.clubId);

    if (club == null) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(),
        appBar: AppBar(
          title: Text(
            _getText('Détails du club', 'Club details', 'Detalles del club'),
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
          child: Text(
            _getText('Club non trouvé', 'Club not found', 'Club no encontrado'),
            style: TextStyle(color: _getTextColor()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          club.name,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              club.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              club.category,
              style: TextStyle(color: _getMutedTextColor()),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              color: _getCardColor(),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getText('Description', 'Description', 'Descripción'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      club.description,
                      style: TextStyle(color: _getTextColor()),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.person,
                      _getText('Président', 'President', 'Presidente'),
                      club.presidentName,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.people,
                      _getText('Membres', 'Members', 'Miembros'),
                      _getText('${club.memberCount} membres', '${club.memberCount} members', '${club.memberCount} miembros'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = context.read<AuthViewModel>().currentUser?.id ?? '';
                  final userName = context.read<AuthViewModel>().currentUser?.fullName ?? '';
                  
                  final success = await viewModel.joinClub(widget.clubId, userId, userName);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success 
                              ? _getText('Vous avez rejoint le club!', 'You joined the club!', '¡Te has unido al club!')
                              : _getText('Erreur', 'Error', 'Error'),
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                    if (success) {
                      context.go('/clubs');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_getText('Rejoindre le club', 'Join club', 'Unirse al club')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: _getMutedTextColor()),
          ),
        ),
      ],
    );
  }
}