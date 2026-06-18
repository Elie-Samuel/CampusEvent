import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/themes/app_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String code;
  final String? role;
  
  const ResetPasswordPage({
    super.key, 
    required this.email, 
    required this.code,
    this.role,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return _getText('Administrateur', 'Administrator', 'Administrador');
      case 'organizer':
        return _getText('Organisateur', 'Organizer', 'Organizador');
      case 'club_president':
        return _getText('Chef de club', 'Club president', 'Presidente del club');
      case 'student':
        return _getText('Étudiant', 'Student', 'Estudiante');
      default:
        return '';
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

  Color _getBorderColor() {
    return _isDarkMode ? AppTheme.darkBorder : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final viewModel = context.watch<AuthViewModel>();
    
    final roleLabel = _getRoleLabel(widget.role);
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Nouveau mot de passe', 'New password', 'Nueva contraseña'),
          style: TextStyle(color: _getTextColor()),
        ),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Icon centré
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Color(0xFFFF6D00),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Titre centré
              Center(
                child: Text(
                  _getText('Réinitialisation du mot de passe', 'Password reset', 'Restablecimiento de contraseña'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Sous-titre centré
              Center(
                child: Text(
                  roleLabel.isNotEmpty
                      ? _getText(
                          'Choisissez un nouveau mot de passe pour votre compte $roleLabel',
                          'Choose a new password for your $roleLabel account',
                          'Elija una nueva contraseña para su cuenta de $roleLabel',
                        )
                      : _getText(
                          'Choisissez un nouveau mot de passe pour votre compte',
                          'Choose a new password for your account',
                          'Elija una nueva contraseña para su cuenta',
                        ),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getMutedTextColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Formulaire
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getCardColor(),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nouveau mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: _getTextColor()),
                        decoration: InputDecoration(
                          labelText: _getText('Nouveau mot de passe', 'New password', 'Nueva contraseña'),
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: _getMutedTextColor()),
                          labelStyle: TextStyle(color: _getMutedTextColor()),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6D00)),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
                          ),
                          filled: true,
                          fillColor: _isDarkMode ? AppTheme.darkCard : Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('Veuillez entrer un mot de passe', 'Please enter a password', 'Por favor ingrese una contraseña');
                          }
                          if (value.length < 6) {
                            return _getText('Le mot de passe doit contenir au moins 6 caractères', 'Password must be at least 6 characters', 'La contraseña debe tener al menos 6 caracteres');
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirmation mot de passe
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: TextStyle(color: _getTextColor()),
                        decoration: InputDecoration(
                          labelText: _getText('Confirmer le mot de passe', 'Confirm password', 'Confirmar contraseña'),
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: _getMutedTextColor()),
                          labelStyle: TextStyle(color: _getMutedTextColor()),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF6D00)),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: _getBorderColor()),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
                          ),
                          filled: true,
                          fillColor: _isDarkMode ? AppTheme.darkCard : Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _getText('Veuillez confirmer votre mot de passe', 'Please confirm your password', 'Por favor confirme su contraseña');
                          }
                          if (value != _passwordController.text) {
                            return _getText('Les mots de passe ne correspondent pas', 'Passwords do not match', 'Las contraseñas no coinciden');
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Bouton réinitialiser
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await viewModel.resetPasswordWithCode(
                                      widget.email,
                                      widget.code,
                                      _passwordController.text,
                                    );
                                    
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(_getText('Mot de passe réinitialisé avec succès!', 'Password reset successfully!', '¡Contraseña restablecida con éxito!')),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      context.go('/login');
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6D00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getText('Réinitialiser le mot de passe', 'Reset password', 'Restablecer contraseña'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bouton retour centré
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: Text(
                    _getText('Retour à la connexion', 'Back to login', 'Volver al inicio de sesión'),
                    style: TextStyle(color: _getMutedTextColor()),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}