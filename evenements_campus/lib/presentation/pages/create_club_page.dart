import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/club.dart';
import '../../core/themes/app_theme.dart';

class CreateClubPage extends StatefulWidget {
  const CreateClubPage({super.key});

  @override
  State<CreateClubPage> createState() => _CreateClubPageState();
}

class _CreateClubPageState extends State<CreateClubPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _socialLinksCtrl = TextEditingController();
  
  bool _isSubmitting = false;
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _socialLinksCtrl.dispose();
    super.dispose();
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
    return _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  }

  Color _getBorderColor() {
    return _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    
    // Vérifier si l'utilisateur peut créer un club
    if (!auth.canCreateClub()) {
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
          child: Text(
            _getText('Vous n\'avez pas la permission de créer un club.', 'You do not have permission to create a club.', 'No tienes permiso para crear un club.'),
            style: TextStyle(color: _getTextColor()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Créer un club', 'Create a club', 'Crear un club'),
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
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du club
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(color: _getTextColor()),
                      decoration: InputDecoration(
                        labelText: _getText('Nom du club *', 'Club name *', 'Nombre del club *'),
                        labelStyle: TextStyle(color: _getMutedTextColor()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _getCardColor(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return _getText('Nom requis', 'Name required', 'Nombre requerido');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 5,
                      style: TextStyle(color: _getTextColor()),
                      decoration: InputDecoration(
                        labelText: _getText('Description *', 'Description *', 'Descripción *'),
                        labelStyle: TextStyle(color: _getMutedTextColor()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _getCardColor(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return _getText('Description requise', 'Description required', 'Descripción requerida');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Catégorie
                    TextFormField(
                      controller: _categoryCtrl,
                      style: TextStyle(color: _getTextColor()),
                      decoration: InputDecoration(
                        labelText: _getText('Catégorie', 'Category', 'Categoría'),
                        hintText: _getText('Sport, Culture, Technologie...', 'Sport, Culture, Technology...', 'Deporte, Cultura, Tecnología...'),
                        hintStyle: TextStyle(color: _getMutedTextColor()),
                        labelStyle: TextStyle(color: _getMutedTextColor()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _getCardColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Liens sociaux
                    TextFormField(
                      controller: _socialLinksCtrl,
                      style: TextStyle(color: _getTextColor()),
                      decoration: InputDecoration(
                        labelText: _getText('Liens sociaux', 'Social links', 'Enlaces sociales'),
                        hintText: _getText('Facebook, Instagram, Twitter...', 'Facebook, Instagram, Twitter...', 'Facebook, Instagram, Twitter...'),
                        hintStyle: TextStyle(color: _getMutedTextColor()),
                        labelStyle: TextStyle(color: _getMutedTextColor()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor()),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: _getCardColor(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Bouton de soumission
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getText('Créer le club', 'Create club', 'Crear club'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final auth = context.read<AuthViewModel>();
    final clubViewModel = context.read<ClubViewModel>();
    
    final club = Club(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text,
      description: _descCtrl.text,
      category: _categoryCtrl.text.isEmpty ? _getText('Général', 'General', 'General') : _categoryCtrl.text,
      presidentId: auth.currentUser!.id,
      presidentName: auth.currentUser!.fullName,
      memberCount: 1,
      socialLinks: _socialLinksCtrl.text.isEmpty ? null : _socialLinksCtrl.text,
    );
    
    final success = await clubViewModel.createClub(club);
    
    setState(() => _isSubmitting = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('Club créé avec succès !', 'Club created successfully!', '¡Club creado con éxito!')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted && clubViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(clubViewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}