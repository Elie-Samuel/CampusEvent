import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../core/themes/app_theme.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final String? role;
  
  const VerifyCodePage({
    super.key, 
    required this.email,
    this.role,
  });

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isDarkMode = false;
  String _languageCode = 'fr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startTimer();
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

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (_remainingSeconds > 0 && mounted) {
      setState(() {
        _remainingSeconds--;
        _canResend = false;
      });
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    } else if (mounted) {
      setState(() {
        _canResend = true;
      });
    }
  }

  String get _enteredCode {
    return _codeControllers.map((c) => c.text).join();
  }

  void _clearCode() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
    return _isDarkMode ? AppTheme.darkBorder : Colors.grey[300]!;
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
          _getText('Vérification du code', 'Verify code', 'Verificar código'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Icon
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6D00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pin,
                    size: 50,
                    color: Color(0xFFFF6D00),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                _getText('Code de vérification', 'Verification code', 'Código de verificación'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                roleLabel.isNotEmpty
                    ? _getText(
                        'Un code à 6 chiffres a été envoyé à\n${widget.email} (compte $roleLabel)',
                        'A 6-digit code has been sent to\n${widget.email} ($roleLabel account)',
                        'Se ha enviado un código de 6 dígitos a\n${widget.email} (cuenta de $roleLabel)',
                      )
                    : _getText(
                        'Un code à 6 chiffres a été envoyé à\n${widget.email}',
                        'A 6-digit code has been sent to\n${widget.email}',
                        'Se ha enviado un código de 6 dígitos a\n${widget.email}',
                      ),
                style: TextStyle(
                  fontSize: 14,
                  color: _getMutedTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Code input à 6 cases
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Les 6 cases
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) => _buildCodeBox(index)),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bouton pour coller le code
                      TextButton.icon(
                        onPressed: () {
                          _showPasteDialog();
                        },
                        icon: const Icon(Icons.content_paste, size: 18, color: Color(0xFFFF6D00)),
                        label: Text(
                          _getText('Coller le code', 'Paste code', 'Pegar código'),
                          style: const TextStyle(color: Color(0xFFFF6D00)),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      if (viewModel.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      
                      // Bouton vérifier
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  if (_enteredCode.length == 6) {
                                    final isValid = await viewModel.verifyResetCode(
                                      widget.email,
                                      _enteredCode,
                                    );
                                    
                                    if (isValid && mounted) {
                                      context.push('/reset-password', extra: {
                                        'email': widget.email,
                                        'code': _enteredCode,
                                        'role': widget.role,
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_getText('Veuillez entrer le code complet (6 chiffres)', 'Please enter the complete code (6 digits)', 'Por favor ingrese el código completo (6 dígitos)')),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6D00),
                            foregroundColor: Colors.white,
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
                                  _getText('Vérifier le code', 'Verify code', 'Verificar código'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Bouton renvoyer
                      if (_canResend)
                        TextButton(
                          onPressed: () async {
                            Map<String, dynamic> result;
                            if (widget.role != null && widget.role!.isNotEmpty) {
                              result = await viewModel.sendResetCodeWithRole(
                                widget.email,
                                widget.role!,
                              );
                            } else {
                              result = await viewModel.sendResetCode(widget.email);
                            }
                            
                            if (result['success'] == true && mounted) {
                              setState(() {
                                _remainingSeconds = 60;
                                _canResend = false;
                                _clearCode();
                              });
                              _startTimer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_getText('Nouveau code envoyé!', 'New code sent!', '¡Nuevo código enviado!')),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (mounted && result['success'] == false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? _getText('Erreur lors de l\'envoi', 'Error sending', 'Error al enviar')),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            _getText('Renvoyer le code', 'Resend code', 'Reenviar código'),
                            style: const TextStyle(
                              color: Color(0xFFFF6D00),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        )
                      else
                        Text(
                          _getText(
                            'Renvoyer dans $_remainingSeconds secondes',
                            'Resend in $_remainingSeconds seconds',
                            'Reenviar en $_remainingSeconds segundos',
                          ),
                          style: TextStyle(
                            color: _getMutedTextColor(),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  _getText('Retour à la connexion', 'Back to login', 'Volver al inicio de sesión'),
                  style: TextStyle(color: _getMutedTextColor()),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF6D00),
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
          ),
          filled: true,
          fillColor: _getCardColor(),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
          
          // Auto-validation quand le code est complet
          if (_enteredCode.length == 6) {
            _autoVerify();
          }
        },
      ),
    );
  }

  void _autoVerify() async {
    final viewModel = context.read<AuthViewModel>();
    if (!viewModel.isLoading && _enteredCode.length == 6) {
      final isValid = await viewModel.verifyResetCode(
        widget.email,
        _enteredCode,
      );
      
      if (isValid && mounted) {
        context.push('/reset-password', extra: {
          'email': widget.email,
          'code': _enteredCode,
          'role': widget.role,
        });
      }
    }
  }

  void _showPasteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(_getText('Coller le code', 'Paste code', 'Pegar código'), style: TextStyle(color: _getTextColor())),
        content: TextField(
          style: TextStyle(color: _getTextColor()),
          decoration: InputDecoration(
            hintText: _getText('Entrez le code à 6 chiffres', 'Enter the 6-digit code', 'Ingrese el código de 6 dígitos'),
            hintStyle: TextStyle(color: _getMutedTextColor()),
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
              borderSide: const BorderSide(color: Color(0xFFFF6D00), width: 2),
            ),
            filled: true,
            fillColor: _getCardColor(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          onChanged: (value) {
            if (value.length == 6) {
              for (int i = 0; i < 6; i++) {
                _codeControllers[i].text = value[i];
              }
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_enteredCode.length == 6) {
                  _autoVerify();
                }
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('Annuler', 'Cancel', 'Cancelar'), style: TextStyle(color: _getMutedTextColor())),
          ),
        ],
      ),
    );
  }
}