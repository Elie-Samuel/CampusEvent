import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/loading_widget.dart';
import '../../domain/entities/notification.dart';
import '../../core/themes/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  String? _selectedRole;
  bool _showForm = false;
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  static const Color primaryOrange = Color(0xFFFF6D00);
  static const Color primaryGrey = Color(0xFF757575);

  // ✅ Tous les rôles disponibles pour la connexion (incluant admin)
  List<Map<String, dynamic>> get _roles {
    return [
      {
        'value': 'admin', 
        'label': _getText('Administrateur', 'Administrator', 'Administrador'),
        'icon': Icons.admin_panel_settings, 
        'color': Colors.purple, 
        'description': _getText('Accès complet à toutes les fonctionnalités', 'Full access to all features', 'Acceso completo a todas las funciones')
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
      {
        'value': 'student', 
        'label': _getText('Étudiant', 'Student', 'Estudiante'),
        'icon': Icons.school, 
        'color': Colors.orange, 
        'description': _getText('Participer aux événements du campus', 'Participate in campus events', 'Participa en eventos del campus')
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
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

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showForm = true;
      _emailCtrl.clear();
      _passCtrl.clear();
    });
  }

  void _goBack() {
    setState(() {
      _selectedRole = null;
      _showForm = false;
      _emailCtrl.clear();
      _passCtrl.clear();
    });
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
    return _isDarkMode ? AppTheme.darkTextMuted : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const LoadingWidget();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 16),
                  Text(
                    'CampusEvent',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getText(
                      'Connectez-vous à votre espace',
                      'Login to your space',
                      'Inicia sesión en tu espacio',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: _getMutedTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  if (!_showForm) 
                    _buildRoleSelection()
                  else 
                    _buildLoginForm(vm),
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
          _getText('Sélectionnez votre rôle', 'Select your role', 'Selecciona tu rol'),
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
            Flexible(
              child: Text(
                _getText("Pas encore de compte ? ", "Don't have an account? ", "¿No tienes cuenta? "),
                style: TextStyle(color: _getMutedTextColor(), fontSize: 14),
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/register'),
              child: Text(
                _getText("Créer un compte", "Create an account", "Crear una cuenta"),
                style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 14),
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

  Widget _buildLoginForm(AuthViewModel vm) {
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
                    'Connexion en tant que $roleLabel',
                    'Login as $roleLabel',
                    'Iniciar sesión como $roleLabel',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: _getTextColor()),
                decoration: InputDecoration(
                  labelText: _getText('Adresse email', 'Email address', 'Correo electrónico'),
                  hintText: 'exemple@campus.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryOrange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : primaryGrey.withAlpha(50)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  hintStyle: TextStyle(color: _getMutedTextColor()),
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
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _getMutedTextColor(),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  fillColor: _isDarkMode ? AppTheme.darkCard : const Color(0xFFFAFAFA),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryOrange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _isDarkMode ? AppTheme.darkBorder : primaryGrey.withAlpha(50)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: TextStyle(color: _getMutedTextColor()),
                  hintStyle: TextStyle(color: _getMutedTextColor()),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _remember,
                        onChanged: (v) => setState(() => _remember = v ?? false),
                        activeColor: primaryOrange,
                        checkColor: Colors.white,
                      ),
                      Text(
                        _getText('Se souvenir', 'Remember me', 'Recordarme'),
                        style: TextStyle(color: _getTextColor(), fontSize: 13),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _getText('Mot de passe oublié ?', 'Forgot password?', '¿Olvidaste tu contraseña?'),
                      style: TextStyle(color: primaryOrange, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (vm.errorMessage != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: vm.errorMessage!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final notificationViewModel = context.read<NotificationViewModel>();
                      final success = await vm.login(
                        _emailCtrl.text.trim(),
                        _passCtrl.text,
                      );
                      if (success && mounted) {
                        if (vm.currentUser != null) {
                          notificationViewModel.setCurrentUser(vm.currentUser!.id);
                          await notificationViewModel.loadNotifications();
                          if (notificationViewModel.notifications.isEmpty) {
                            final welcomeNotification = AppNotification(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              userId: vm.currentUser!.id,
                              title: _getText('Bon retour sur CampusEvent !', 'Welcome back to CampusEvent!', '¡Bienvenido de vuelta a CampusEvent!'),
                              body: _getText('Découvrez les nouveaux événements', 'Discover new events', 'Descubre nuevos eventos'),
                              type: 'welcome',
                              createdAt: DateTime.now(),
                            );
                            await notificationViewModel.addNotification(welcomeNotification);
                          }
                        }
                        context.go('/home');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _getText('Se connecter', 'Login', 'Iniciar sesión'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryOrange.withAlpha(50),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.event_note, size: 48, color: primaryOrange);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }
}