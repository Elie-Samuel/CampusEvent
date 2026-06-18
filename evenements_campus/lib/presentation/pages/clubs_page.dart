import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/club_card.dart';
import '../../core/themes/app_theme.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
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

  Color _getTextColor() {
    return _isDarkMode ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final viewModel = context.watch<ClubViewModel>();

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Clubs', 'Clubs', 'Clubes'),
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
          if (auth.canCreateClub())
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              onPressed: () {
                context.push('/create-club');
              },
              tooltip: _getText('Créer un club', 'Create a club', 'Crear un club'),
            ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.clubs.isEmpty
              ? _buildEmptyState(context, auth)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.clubs.length,
                  itemBuilder: (context, index) {
                    final club = viewModel.clubs[index];
                    final canEdit = auth.canEditClub(club.presidentId);
                    return ClubCard(
                      club: club,
                      canEdit: canEdit,
                      isDarkMode: _isDarkMode,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AuthViewModel auth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: _getMutedTextColor(),
          ),
          const SizedBox(height: 16),
          Text(
            _getText('Aucun club disponible', 'No clubs available', 'No hay clubes disponibles'),
            style: TextStyle(fontSize: 16, color: _getMutedTextColor()),
          ),
          const SizedBox(height: 16),
          if (auth.canCreateClub())
            ElevatedButton.icon(
              onPressed: () => context.push('/create-club'),
              icon: const Icon(Icons.add),
              label: Text(_getText('Créer un club', 'Create a club', 'Crear un club')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}