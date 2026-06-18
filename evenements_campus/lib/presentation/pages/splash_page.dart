import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _slideUp;
  late Animation<double> _pulse;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    // Animation principale
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Animation d'échelle du logo
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    
    // Animation de fondu
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    // Animation de glissement du texte
    _slideUp = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Animation de pulsation du loader
    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeInOutSine,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _ctrl.repeat(reverse: true);
        }
      });
    
    _ctrl.forward();

    // Navigation après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    return _isDarkMode ? AppTheme.darkBackground : Colors.white;
  }

  Color _getTextColor() {
    return _isDarkMode ? AppTheme.darkText : const Color(0xFF1A237E);
  }

  Color _getSecondaryTextColor() {
    return _isDarkMode ? AppTheme.darkTextMuted : const Color(0xFFFF6D00);
  }

  Color _getGradientStartColor() {
    return _isDarkMode ? AppTheme.darkBackground : Colors.white;
  }

  Color _getGradientEndColor() {
    return _isDarkMode ? AppTheme.darkSurface : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradientStartColor(),
              _getGradientEndColor(),
              _isDarkMode 
                  ? AppTheme.darkCard.withOpacity(0.05)
                  : const Color(0xFF1A237E).withOpacity(0.05),
              _isDarkMode 
                  ? AppTheme.primaryColor.withOpacity(0.02)
                  : const Color(0xFFFF6D00).withOpacity(0.02),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Stack(
            children: [
              // Background circles decoration
              _buildBackgroundCircles(screenWidth, screenHeight),
              
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo avec animation
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: _getBackgroundColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6D00).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: _isDarkMode 
                                    ? AppTheme.darkTextMuted.withOpacity(0.2)
                                    : const Color(0xFF1A237E).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(65),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFF6D00),
                                        _isDarkMode ? AppTheme.darkCard : const Color(0xFF1A237E),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.event_available,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Titre avec animation
                    Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: FadeTransition(
                        opacity: _fade,
                        child: Column(
                          children: [
                            Text(
                              'CampusEvent',
                              style: GoogleFonts.poppins(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Votre campus, vos événements',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: _getSecondaryTextColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Loader moderne avec animation de pulsation
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF6D00),
                            width: 2,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6D00),
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackgroundCircles(double width, double height) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: BackgroundPainter(
            isDarkMode: _isDarkMode,
          ),
        ),
      ),
    );
  }
}

// Custom painter pour le fond décoratif
class BackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  BackgroundPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? AppTheme.darkTextMuted : const Color(0xFFFF6D00)).withOpacity(0.03)
      ..style = PaintingStyle.fill;
    
    // Cercle en haut à droite
    canvas.drawCircle(
      Offset(size.width - 50, 50),
      150,
      paint,
    );
    
    // Cercle en bas à gauche
    paint.color = (isDarkMode ? AppTheme.darkText : const Color(0xFF1A237E)).withOpacity(0.03);
    canvas.drawCircle(
      Offset(50, size.height - 50),
      200,
      paint,
    );
    
    // Petit cercle au centre
    paint.color = (isDarkMode ? AppTheme.primaryColor : const Color(0xFFFF6D00)).withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 1.5,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}