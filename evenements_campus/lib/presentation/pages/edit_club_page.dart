import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/club_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/club.dart';
import '../../core/themes/app_theme.dart';

class EditClubPage extends StatefulWidget {
  final Club club;
  const EditClubPage({super.key, required this.club});

  @override
  State<EditClubPage> createState() => _EditClubPageState();
}

class _EditClubPageState extends State<EditClubPage> {
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
    // Remplir les champs avec les données existantes
    _nameCtrl.text = widget.club.name;
    _descCtrl.text = widget.club.description;
    _categoryCtrl.text = widget.club.category;
    _socialLinksCtrl.text = widget.club.socialLinks ?? '';
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
    
    // Vérifier si l'utilisateur peut modifier ce club
    if (!auth.canEditClub(widget.club.presidentId)) {
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
              Icon(Icons.lock, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _getText('Vous n\'avez pas la permission', 'You do not have permission', 'No tienes permiso'),
                style: TextStyle(fontSize: 16, color: _getMutedTextColor()),
              ),
              Text(
                _getText('de modifier ce club.', 'to edit this club.', 'para editar este club.'),
                style: TextStyle(fontSize: 16, color: _getMutedTextColor()),
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
          _getText('Modifier le club', 'Edit club', 'Editar club'),
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
                        prefixIcon: Icon(Icons.group, color: AppTheme.primaryColor),
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
                        prefixIcon: Icon(Icons.description, color: AppTheme.primaryColor),
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
                        prefixIcon: Icon(Icons.category, color: AppTheme.primaryColor),
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
                        prefixIcon: Icon(Icons.link, color: AppTheme.primaryColor),
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
                    
                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _getMutedTextColor(),
                              side: BorderSide(color: _getBorderColor()),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(_getText('Annuler', 'Cancel', 'Cancelar'), style: TextStyle(color: _getMutedTextColor())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _getText('Enregistrer', 'Save', 'Guardar'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final clubViewModel = context.read<ClubViewModel>();
    
    final updatedClub = widget.club.copyWith(
      name: _nameCtrl.text,
      description: _descCtrl.text,
      category: _categoryCtrl.text.isEmpty ? _getText('Général', 'General', 'General') : _categoryCtrl.text,
      socialLinks: _socialLinksCtrl.text.isEmpty ? null : _socialLinksCtrl.text,
    );
    
    final success = await clubViewModel.updateClub(updatedClub);
    
    setState(() => _isSubmitting = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('Club modifié avec succès !', 'Club updated successfully!', '¡Club actualizado con éxito!')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
      context.pop(); // Retour à la page des clubs
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