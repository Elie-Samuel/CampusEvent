import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/themes/app_theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _selectedRole;
  bool _showRoleSelection = true;
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  List<Map<String, dynamic>> get _roles {
    return [
      {'value': 'admin', 'label': _getText('Administrateur', 'Administrator', 'Administrador'), 'icon': Icons.admin_panel_settings, 'color': Colors.purple},
      {'value': 'organizer', 'label': _getText('Organisateur', 'Organizer', 'Organizador'), 'icon': Icons.event, 'color': Colors.blue},
      {'value': 'club_president', 'label': _getText('Chef de club', 'Club president', 'Presidente del club'), 'icon': Icons.people, 'color': Colors.green},
      {'value': 'student', 'label': _getText('Étudiant', 'Student', 'Estudiante'), 'icon': Icons.school, 'color': Colors.orange},
    ];
  }

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
    _emailController.dispose();
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
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.grey[600]!;
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showRoleSelection = false;
    });
  }

  void _goBack() {
    setState(() {
      _selectedRole = null;
      _showRoleSelection = true;
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final viewModel = context.watch<AuthViewModel>();
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Mot de passe oublié', 'Forgot password', 'Olvidé mi contraseña'),
          style: TextStyle(color: _getTextColor()),
        ),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icon
              Container(
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
              
              const SizedBox(height: 24),
              
              Text(
                _getText('Mot de passe oublié?', 'Forgot password?', '¿Olvidaste tu contraseña?'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                _showRoleSelection 
                    ? _getText('Sélectionnez votre rôle pour continuer', 'Select your role to continue', 'Selecciona tu rol para continuar')
                    : _getText('Entrez votre adresse email pour recevoir\nun code de réinitialisation', 'Enter your email to receive\na reset code', 'Ingresa tu correo para recibir\nun código de reinicio'),
                style: TextStyle(
                  fontSize: 14,
                  color: _getMutedTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),

              if (_showRoleSelection)
                _buildRoleSelection()
              else
                _buildEmailForm(viewModel),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: _roles.map((role) {
        final color = role['color'] as Color;
        final label = role['label'] as String;
        final value = role['value'] as String;
        
        return GestureDetector(
          onTap: () => _selectRole(value),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCardColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(50), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(role['icon'], size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getText(
                          'Réinitialiser le mot de passe pour un compte $label',
                          'Reset password for $label account',
                          'Restablecer contraseña para cuenta de $label',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getMutedTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: color),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmailForm(AuthViewModel viewModel) {
    final roles = _roles;
    final selectedRoleData = roles.firstWhere(
      (r) => r['value'] == _selectedRole,
      orElse: () => roles.last,
    );
    final roleColor = selectedRoleData['color'] as Color;
    final roleLabel = selectedRoleData['label'] as String;
    final roleIcon = selectedRoleData['icon'] as IconData;

    return Column(
      children: [
        // Badge rôle sélectionné
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [roleColor.withAlpha(30), roleColor.withAlpha(10)],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: roleColor.withAlpha(50), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: roleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(roleIcon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getText(
                    'Réinitialisation pour $roleLabel',
                    'Reset for $roleLabel',
                    'Reinicio para $roleLabel',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: roleColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: roleColor),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Container(
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
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: _getTextColor()),
                  decoration: InputDecoration(
                    labelText: _getText('Email', 'Email', 'Correo electrónico'),
                    hintText: 'exemple@email.com',
                    hintStyle: TextStyle(color: _getMutedTextColor()),
                    labelStyle: TextStyle(color: _getMutedTextColor()),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFFFF6D00),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF6D00),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: _isDarkMode ? AppTheme.darkCard : Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _getText('Veuillez entrer votre email', 'Please enter your email', 'Por favor ingrese su correo');
                    }
                    if (!value.contains('@')) {
                      return _getText('Email invalide', 'Invalid email', 'Correo inválido');
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
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
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final result = await viewModel.sendResetCodeWithRole(
                              _emailController.text,
                              _selectedRole!,
                            );
                            
                            if (result['success'] == true && mounted) {
                              context.push('/verify-code', extra: {
                                'email': _emailController.text,
                                'role': _selectedRole,
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _getText('Envoyer le code', 'Send code', 'Enviar código'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text(
            _getText('Retour à la connexion', 'Back to login', 'Volver al inicio de sesión'),
            style: TextStyle(color: _getMutedTextColor()),
          ),
        ),
      ],
    );
  }
}