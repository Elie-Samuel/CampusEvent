import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/loading_widget.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/notification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _selectedRole;
  bool _showForm = false;
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  // ✅ Liste des rôles disponibles à l'inscription (sans admin)
  List<Map<String, dynamic>> get _roles {
    return [
      {
        'value': 'student', 
        'label': _getText('Étudiant', 'Student', 'Estudiante'), 
        'icon': Icons.school, 
        'color': Colors.orange, 
        'description': _getText('Participer aux événements du campus', 'Participate in campus events', 'Participa en eventos del campus')
      },
      {
        'value': 'organizer', 
        'label': _getText('Organisateur', 'Organizer', 'Organizador'), 
        'icon': Icons.event, 
        'color': Colors.blue, 
        'description': _getText('Créer et gérer vos événements', 'Create and manage your events', 'Crear y gestionar tus eventos')
      },
      {
        'value': 'club_president', 
        'label': _getText('Chef de club', 'Club president', 'Presidente del club'), 
        'icon': Icons.people, 
        'color': Colors.green, 
        'description': _getText('Gérer votre club et ses membres', 'Manage your club and its members', 'Gestiona tu club y sus miembros')
      },
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showForm = true;
    });
  }

  void _goBack() {
    setState(() {
      _selectedRole = null;
      _showForm = false;
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passCtrl.clear();
      _confirmCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText("Créer un compte", "Create account", "Crear cuenta"),
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
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const LoadingWidget();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    _getText('Rejoignez CampusEvent', 'Join CampusEvent', 'Únete a CampusEvent'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getTextColor()),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getText('Inscrivez-vous pour accéder à tous les événements', 'Sign up to access all events', 'Regístrate para acceder a todos los eventos'),
                    style: TextStyle(fontSize: 13, color: _getMutedTextColor()),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  if (!_showForm)
                    _buildRoleSelection()
                  else
                    _buildRegistrationForm(vm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        Text(
          _getText('Choisissez votre rôle', 'Choose your role', 'Elige tu rol'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _getTextColor(),
          ),
        ),
        const SizedBox(height: 20),
        ..._roles.map((role) => _buildRoleCard(role)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getText("Déjà un compte ? ", "Already have an account? ", "¿Ya tienes una cuenta? "),
              style: TextStyle(color: _getTextColor(), fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                _getText("Se connecter", "Login", "Iniciar sesión"),
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final color = role['color'] as Color;
    
    return GestureDetector(
      onTap: () => _selectRole(role['value']),
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
                    role['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role['description'],
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
  }

  Widget _buildRegistrationForm(AuthViewModel vm) {
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
            boxShadow: [
              BoxShadow(
                color: roleColor.withAlpha(30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
                    'Inscription en tant que $roleLabel',
                    'Registration as $roleLabel',
                    'Registro como $roleLabel',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                  overflow: TextOverflow.visible,
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
        const SizedBox(height: 32),

        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: _getTextColor()),
                decoration: InputDecoration(
                  labelText: _getText('Nom complet', 'Full name', 'Nombre completo'),
                  hintText: 'Rakotomalala Rija',
                  hintStyle: TextStyle(color: _getMutedTextColor()),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
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
                  if (v == null || v.trim().isEmpty) {
                    return _getText('Veuillez entrer votre nom', 'Please enter your name', 'Por favor ingrese su nombre');
                  }
                  if (v.trim().length < 3) {
                    return _getText('Nom trop court', 'Name too short', 'Nombre demasiado corto');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                style: TextStyle(color: _getTextColor()),
                decoration: InputDecoration(
                  labelText: _getText('Adresse email', 'Email address', 'Correo electrónico'),
                  hintText: 'exemple@campus.com',
                  hintStyle: TextStyle(color: _getMutedTextColor()),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
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
                  if (v == null || v.trim().isEmpty) {
                    return _getText('Veuillez entrer votre email', 'Please enter your email', 'Por favor ingrese su correo');
                  }
                  if (!v.contains('@')) {
                    return _getText('Email invalide', 'Invalid email', 'Correo inválido');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: TextStyle(color: _getTextColor()),
                decoration: InputDecoration(
                  labelText: _getText('Mot de passe', 'Password', 'Contraseña'),
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: _getMutedTextColor()),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _getMutedTextColor(),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
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
                    return _getText('Veuillez entrer votre mot de passe', 'Please enter your password', 'Por favor ingrese su contraseña');
                  }
                  if (v.length < 6) {
                    return _getText('Minimum 6 caractères', 'Minimum 6 characters', 'Mínimo 6 caracteres');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure,
                style: TextStyle(color: _getTextColor()),
                decoration: InputDecoration(
                  labelText: _getText('Confirmer le mot de passe', 'Confirm password', 'Confirmar contraseña'),
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: _getMutedTextColor()),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
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
                    return _getText('Veuillez confirmer votre mot de passe', 'Please confirm your password', 'Por favor confirme su contraseña');
                  }
                  if (v != _passCtrl.text) {
                    return _getText('Les mots de passe ne correspondent pas', 'Passwords do not match', 'Las contraseñas no coinciden');
                  }
                  return null;
                },
              ),
              if (vm.errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: vm.errorMessage!, isDarkMode: _isDarkMode),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final notificationViewModel = context.read<NotificationViewModel>();
                      final success = await vm.register(
                        _emailCtrl.text.trim(),
                        _passCtrl.text,
                        _nameCtrl.text.trim(),
                        role: _selectedRole!,
                      );
                      if (success && mounted) {
                        if (vm.currentUser != null) {
                          notificationViewModel.setCurrentUser(vm.currentUser!.id);
                          await notificationViewModel.loadNotifications();
                          
                          final welcomeNotification = AppNotification(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: vm.currentUser!.id,
                            title: _getText('Bienvenue sur CampusEvent !', 'Welcome to CampusEvent!', '¡Bienvenido a CampusEvent!'),
                            body: _getText(
                              'Vous êtes inscrit en tant que $roleLabel',
                              'You are registered as $roleLabel',
                              'Estás registrado como $roleLabel',
                            ),
                            type: 'welcome',
                            createdAt: DateTime.now(),
                          );
                          await notificationViewModel.addNotification(welcomeNotification);
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_getText('Compte créé avec succès !', 'Account created successfully!', '¡Cuenta creada con éxito!')),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                        context.go('/login');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _getText("S'inscrire", "Sign up", "Registrarse"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getText("Déjà un compte ? ", "Already have an account? ", "¿Ya tienes una cuenta? "),
              style: TextStyle(color: _getTextColor(), fontSize: 14),
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                _getText("Se connecter", "Login", "Iniciar sesión"),
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDarkMode;

  const _ErrorBanner({
    required this.message,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}