import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/event_viewmodel.dart';
import '../../data/models/user_model.dart';
import '../../services/image_picker_service.dart';
import '../../services/image_upload_service.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/logout_dialog.dart';
import '../../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  bool _editing = false;
  bool _showPasswordFields = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  
  File? _selectedImage;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    final user = context.read<AuthViewModel>().currentUser;
    _nameCtrl.text = user?.fullName ?? '';
    _emailCtrl.text = user?.email ?? '';
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _languageCode = prefs.getString('language') ?? 'fr';
    });
  }

  void _refreshTheme() {
    _loadSettings();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin': 
        return _getText('Administrateur', 'Administrator', 'Administrador');
      case 'organizer': 
        return _getText('Organisateur', 'Organizer', 'Organizador');
      case 'club_president': 
        return _getText('Chef de club', 'Club president', 'Presidente del club');
      default: 
        return _getText('Étudiant', 'Student', 'Estudiante');
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'organizer': return Colors.blue;
      case 'club_president': return Colors.green;
      default: return AppTheme.primaryColor;
    }
  }

  String _getLevel(String? role) {
    switch (role) {
      case 'admin': return '∞';
      case 'organizer': return '3';
      case 'club_president': return '2';
      default: return '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final events = context.watch<EventViewModel>();
    final user = auth.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myAppState = MyAppState.of(context);
      if (myAppState != null) {
        _refreshTheme();
      }
    });

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        title: Text(
          _getText('Mon profil', 'My profile', 'Mi perfil'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (_editing) {
                _selectedImage = null;
                _showPasswordFields = false;
                final currentUser = auth.currentUser;
                _nameCtrl.text = currentUser?.fullName ?? '';
                _emailCtrl.text = currentUser?.email ?? '';
                _passwordCtrl.clear();
                _confirmPasswordCtrl.clear();
              }
              _editing = !_editing;
              if (_editing) {
                _showPasswordFields = false;
              }
            }),
            child: Text(
              _editing 
                  ? _getText('Annuler', 'Cancel', 'Cancelar')
                  : _getText('Modifier', 'Edit', 'Editar'),
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildAvatar(auth),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? _getText('Utilisateur', 'User', 'Usuario'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: _getMutedTextColor(), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  // Badge de rôle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user?.role).withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleLabel(user?.role),
                      style: TextStyle(
                        color: _getRoleColor(user?.role),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      _ProfileStat(
                        value: '${events.userEvents.length}',
                        label: _getText('Événements', 'Events', 'Eventos'),
                        isDarkMode: _isDarkMode,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
                      ),
                      _ProfileStat(
                        value: '0',
                        label: _getText('Clubs', 'Clubs', 'Clubes'),
                        isDarkMode: _isDarkMode,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
                      ),
                      _ProfileStat(
                        value: _getLevel(user?.role),
                        label: _getText('Niveau', 'Level', 'Nivel'),
                        isDarkMode: _isDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Divider(
                    height: 1,
                    color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
                  ),
                  const SizedBox(height: 24),
                  if (_editing) _buildEditForm(auth),
                  if (!_editing) ...[
                    _ActionTile(
                      icon: Icons.event_outlined,
                      label: _getText('Mes événements', 'My events', 'Mis eventos'),
                      trailing: Text(
                        '${events.userEvents.length}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => context.go('/events'),
                      isDarkMode: _isDarkMode,
                    ),
                    _ActionTile(
                      icon: Icons.people_outline,
                      label: _getText('Mes clubs', 'My clubs', 'Mis clubes'),
                      onTap: () => context.go('/clubs'),
                      isDarkMode: _isDarkMode,
                    ),
                    _ActionTile(
                      icon: Icons.settings_outlined,
                      label: _getText('Paramètres', 'Settings', 'Ajustes'),
                      onTap: () => context.push('/settings'),
                      isDarkMode: _isDarkMode,
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
                    ),
                    const SizedBox(height: 8),
                    _ActionTile(
                      icon: Icons.logout,
                      label: _getText('Déconnexion', 'Logout', 'Cerrar sesión'),
                      color: AppTheme.errorColor,
                      onTap: () => LogoutDialog.show(context, auth),
                      isDarkMode: _isDarkMode,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar(AuthViewModel auth) {
    final user = auth.currentUser;
    
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: _getProfileImageWidget(user),
            ),
          ),
          if (_editing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getProfileImageWidget(UserModel? user) {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    
    if (user?.profileImage != null && user!.profileImage!.isNotEmpty) {
      final imageFile = File(user.profileImage!);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        );
      }
    }
    
    return Icon(
      Icons.person,
      size: 52,
      color: AppTheme.primaryColor,
    );
  }

  Widget _buildEditForm(AuthViewModel auth) {
    // ✅ RÈGLES DE PERMISSION
    final bool canEditEmail = auth.isAdmin; // Seul l'admin peut modifier l'email
    final bool canEditName = true; // Tout le monde peut modifier le nom
    final bool canEditPassword = true; // Tout le monde peut modifier le mot de passe
    final bool canEditPhoto = true; // Tout le monde peut modifier la photo

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getText('Modifier les informations', 'Edit information', 'Editar información'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_selectedImage != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getText('Nouvelle photo sélectionnée', 'New photo selected', 'Nueva foto seleccionada'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // ✅ Nom complet - MODIFIABLE PAR TOUS
          TextFormField(
            controller: _nameCtrl,
            enabled: canEditName,
            style: TextStyle(color: _getTextColor()),
            decoration: InputDecoration(
              labelText: _getText('Nom complet *', 'Full name *', 'Nombre completo *'),
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
              filled: true,
              fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              labelStyle: TextStyle(color: _getMutedTextColor()),
              helperText: _getText('Modifiable', 'Editable', 'Modificable'),
              helperStyle: TextStyle(color: Colors.green, fontSize: 11),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return _getText('Nom requis', 'Name required', 'Nombre requerido');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // ✅ Email - MODIFIABLE UNIQUEMENT PAR L'ADMIN
          TextFormField(
            controller: _emailCtrl,
            enabled: canEditEmail,
            style: TextStyle(
              color: canEditEmail ? _getTextColor() : _getMutedTextColor(),
            ),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: _getText('Email *', 'Email *', 'Correo electrónico *'),
              prefixIcon: Icon(Icons.email_outlined, color: canEditEmail ? AppTheme.primaryColor : _getMutedTextColor()),
              filled: true,
              fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: canEditEmail 
                      ? (_isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight)
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: canEditEmail ? AppTheme.primaryColor : Colors.grey.shade300,
                  width: canEditEmail ? 2 : 1,
                ),
              ),
              labelStyle: TextStyle(color: _getMutedTextColor()),
              // ✅ Message d'information selon la permission
              helperText: canEditEmail 
                  ? _getText('Vous pouvez modifier votre email', 'You can change your email', 'Puedes cambiar tu correo')
                  : _getText('L\'email ne peut pas être modifié', 'Email cannot be changed', 'El correo no se puede cambiar'),
              helperStyle: TextStyle(
                color: canEditEmail ? Colors.green : Colors.orange,
                fontSize: 11,
              ),
              // ✅ Indicateur visuel de permission
              suffixIcon: canEditEmail 
                  ? Icon(Icons.edit, color: AppTheme.primaryColor, size: 18)
                  : Icon(Icons.lock_outline, color: Colors.grey, size: 18),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return _getText('Email requis', 'Email required', 'Correo requerido');
              }
              if (!v.contains('@')) {
                return _getText('Email invalide', 'Invalid email', 'Correo inválido');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // ✅ Bouton pour afficher/masquer les champs de mot de passe
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showPasswordFields = !_showPasswordFields;
                if (!_showPasswordFields) {
                  _passwordCtrl.clear();
                  _confirmPasswordCtrl.clear();
                }
              });
            },
            icon: Icon(
              _showPasswordFields ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.primaryColor,
            ),
            label: Text(
              _showPasswordFields 
                  ? _getText('Masquer les champs de mot de passe', 'Hide password fields', 'Ocultar campos de contraseña')
                  : _getText('Changer le mot de passe', 'Change password', 'Cambiar contraseña'),
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          
          if (_showPasswordFields) ...[
            const SizedBox(height: 16),
            // ✅ Nouveau mot de passe - MODIFIABLE PAR TOUS
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              enabled: canEditPassword,
              style: TextStyle(color: _getTextColor()),
              decoration: InputDecoration(
                labelText: _getText('Nouveau mot de passe', 'New password', 'Nueva contraseña'),
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: _getMutedTextColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                labelStyle: TextStyle(color: _getMutedTextColor()),
              ),
              validator: (v) {
                if (_showPasswordFields) {
                  if (v == null || v.isEmpty) {
                    return _getText('Veuillez entrer un mot de passe', 'Please enter a password', 'Por favor ingrese una contraseña');
                  }
                  if (v.length < 6) {
                    return _getText('Minimum 6 caractères', 'Minimum 6 characters', 'Mínimo 6 caracteres');
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // ✅ Confirmation du mot de passe - MODIFIABLE PAR TOUS
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              enabled: canEditPassword,
              style: TextStyle(color: _getTextColor()),
              decoration: InputDecoration(
                labelText: _getText('Confirmer le mot de passe', 'Confirm password', 'Confirmar contraseña'),
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    color: _getMutedTextColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                filled: true,
                fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                labelStyle: TextStyle(color: _getMutedTextColor()),
              ),
              validator: (v) {
                if (_showPasswordFields) {
                  if (v == null || v.isEmpty) {
                    return _getText('Veuillez confirmer votre mot de passe', 'Please confirm your password', 'Por favor confirme su contraseña');
                  }
                  if (v != _passwordCtrl.text) {
                    return _getText('Les mots de passe ne correspondent pas', 'Passwords do not match', 'Las contraseñas no coinciden');
                  }
                }
                return null;
              },
            ),
          ],
          
          const SizedBox(height: 20),
          
          // ✅ Supprimer la photo de profil - MODIFIABLE PAR TOUS
          if (auth.currentUser?.profileImage != null && _selectedImage == null)
            TextButton.icon(
              onPressed: () => _deleteProfileImage(auth),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Text(
                _getText('Supprimer la photo de profil', 'Delete profile picture', 'Eliminar foto de perfil'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 20),
          
          // ✅ Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _editing = false;
                      _selectedImage = null;
                      _showPasswordFields = false;
                      final user = auth.currentUser;
                      _nameCtrl.text = user?.fullName ?? '';
                      _emailCtrl.text = user?.email ?? '';
                      _passwordCtrl.clear();
                      _confirmPasswordCtrl.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight),
                    foregroundColor: _getTextColor(),
                  ),
                  child: Text(_getText('Annuler', 'Cancel', 'Cancelar')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = true;
                            
                            // 1️⃣ Mettre à jour le nom (tous les utilisateurs)
                            if (_nameCtrl.text.trim() != auth.currentUser?.fullName) {
                              success = await auth.updateProfile(
                                _nameCtrl.text.trim(),
                                auth.currentUser?.role ?? 'student',
                                auth.currentUser?.profileImage,
                              );
                            }
                            
                            // 2️⃣ Mettre à jour l'email (UNIQUEMENT ADMIN)
                            if (success && canEditEmail && _emailCtrl.text.trim() != auth.currentUser?.email) {
                              success = await auth.updateEmail(
                                auth.currentUser!.id,
                                _emailCtrl.text.trim(),
                              );
                            }
                            
                            // 3️⃣ Mettre à jour la photo de profil (tous les utilisateurs)
                            if (success && _selectedImage != null) {
                              final imagePath = await _imageUploadService.saveProfileImage(_selectedImage!);
                              if (imagePath != null) {
                                success = await auth.updateProfile(
                                  _nameCtrl.text.trim(),
                                  auth.currentUser?.role ?? 'student',
                                  imagePath,
                                );
                              } else {
                                success = false;
                              }
                            }
                            
                            // 4️⃣ Changer le mot de passe (tous les utilisateurs)
                            if (success && _showPasswordFields && _passwordCtrl.text.isNotEmpty) {
                              success = await auth.changePassword(
                                auth.currentUser!.id,
                                _passwordCtrl.text,
                              );
                            }
                            
                            if (success && mounted) {
                              setState(() {
                                _editing = false;
                                _selectedImage = null;
                                _showPasswordFields = false;
                                _passwordCtrl.clear();
                                _confirmPasswordCtrl.clear();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getText('Profil mis à jour !', 'Profile updated!', '¡Perfil actualizado!')),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            } else if (mounted && auth.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(auth.errorMessage!),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(_getText('Enregistrer', 'Save', 'Guardar')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1,
            color: _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _getCardColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: Text(
                _getText('Prendre une photo', 'Take a photo', 'Tomar una foto'),
                style: TextStyle(color: _getTextColor()),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: Text(
                _getText('Choisir dans la galerie', 'Choose from gallery', 'Elegir de la galería'),
                style: TextStyle(color: _getTextColor()),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final image = await _imagePickerService.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _imagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _deleteProfileImage(AuthViewModel auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(
          _getText('Supprimer la photo', 'Delete photo', 'Eliminar foto'),
          style: TextStyle(color: _getTextColor()),
        ),
        content: Text(
          _getText('Voulez-vous vraiment supprimer votre photo de profil ?', 
                   'Do you really want to delete your profile picture?',
                   '¿Realmente quieres eliminar tu foto de perfil?'),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_getText('Annuler', 'Cancel', 'Cancelar')),
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
      if (auth.currentUser?.profileImage != null) {
        await _imageUploadService.deleteProfileImage(auth.currentUser!.profileImage);
      }
      final success = await auth.updateProfile(
        auth.currentUser?.fullName ?? '',
        auth.currentUser?.role ?? 'student',
        null,
      );
      if (success && mounted) {
        setState(() {
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getText('Photo de profil supprimée', 'Profile picture deleted', 'Foto de perfil eliminada')),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isDarkMode;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color color;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color = Colors.black,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? AppTheme.darkText : color;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color == AppTheme.errorColor ? color : AppTheme.primaryColor),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted),
      onTap: onTap,
    );
  }
}