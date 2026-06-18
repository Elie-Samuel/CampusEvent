import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/app_theme.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'fr';
  String _selectedDateFormat = 'dd/MM/yyyy';
  int _notificationReminder = 30;
  bool _autoDeleteNotifications = false;
  int _autoDeleteDays = 30;
  bool _dataSaverMode = false;

  // Map des langues supportées
  final Map<String, Map<String, String>> _languages = {
    'fr': {'name': 'Français', 'flag': '🇫🇷', 'locale': 'fr_FR'},
    'en': {'name': 'English', 'flag': '🇬🇧', 'locale': 'en_US'},
    'es': {'name': 'Español', 'flag': '🇪🇸', 'locale': 'es_ES'},
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'fr';
      _selectedDateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
      _notificationReminder = prefs.getInt('notification_reminder') ?? 30;
      _autoDeleteNotifications = prefs.getBool('auto_delete_notifications') ?? false;
      _autoDeleteDays = prefs.getInt('auto_delete_days') ?? 30;
      _dataSaverMode = prefs.getBool('data_saver_mode') ?? false;
    });
    
    _updateSystemNavigationBarColor(_darkModeEnabled);
  }

  void _updateSystemNavigationBarColor(bool isDarkMode) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
    
    if (key == 'dark_mode_enabled') {
      _applyThemeChange(value as bool);
    } else if (key == 'language') {
      _applyLanguageChange(value as String);
    }
  }

  void _applyThemeChange(bool isDarkMode) {
    _updateSystemNavigationBarColor(isDarkMode);
    final myAppState = MyAppState.of(context);
    myAppState?.refreshTheme();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thème appliqué instantanément'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _applyLanguageChange(String languageCode) {
    final myAppState = MyAppState.of(context);
    myAppState?.refreshTheme();
    
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Langue changée avec succès'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _getText(String fr, String en, String es) {
    switch (_selectedLanguage) {
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return fr;
    }
  }

  Color _getBackgroundColor() {
    return _darkModeEnabled ? AppTheme.darkBackground : Colors.white;
  }

  Color _getCardColor() {
    return _darkModeEnabled ? AppTheme.darkCard : Colors.white;
  }

  Color _getTextColor() {
    return _darkModeEnabled ? AppTheme.darkText : Colors.black;
  }

  Color _getMutedTextColor() {
    return _darkModeEnabled ? AppTheme.darkTextMuted : AppTheme.textMuted;
  }

  Color _getBorderColor() {
    return _darkModeEnabled ? AppTheme.darkBorder : AppTheme.borderLight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          _getText('Paramètres', 'Settings', 'Ajustes'),
          style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getTextColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Section Apparence
          _buildSectionHeader(_getText('Apparence', 'Appearance', 'Apariencia')),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: _getText('Mode sombre', 'Dark mode', 'Modo oscuro'),
            subtitle: _getText('Activer le thème sombre', 'Enable dark theme', 'Activar tema oscuro'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
              _saveSetting('dark_mode_enabled', value);
              _updateSystemNavigationBarColor(value);
            },
          ),
          _buildLanguageTile(),
          _buildDropdownTile<String>(
            icon: Icons.calendar_today,
            title: _getText('Format de date', 'Date format', 'Formato de fecha'),
            subtitle: _getText('Choisir le format d\'affichage des dates', 'Choose date display format', 'Elige el formato de visualización de fechas'),
            value: _selectedDateFormat,
            items: const [
              DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('DD/MM/YYYY')),
              DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/DD/YYYY')),
              DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('YYYY-MM-DD')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDateFormat = value);
                _saveSetting('date_format', value);
              }
            },
          ),

          Divider(color: _getBorderColor()),

          // Section Notifications
          _buildSectionHeader(_getText('Notifications', 'Notifications', 'Notificaciones')),
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: _getText('Notifications push', 'Push notifications', 'Notificaciones push'),
            subtitle: _getText('Recevoir les notifications', 'Receive notifications', 'Recibir notificaciones'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications_enabled', value);
            },
          ),
          _buildSliderTile(
            icon: Icons.timer,
            title: _getText('Rappel avant événement', 'Event reminder', 'Recordatorio de evento'),
            subtitle: _getText('Minutes avant l\'événement', 'Minutes before event', 'Minutos antes del evento'),
            value: _notificationReminder.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            onChanged: (value) {
              setState(() => _notificationReminder = value.toInt());
              _saveSetting('notification_reminder', _notificationReminder);
            },
            enabled: _notificationsEnabled,
            valueText: '$_notificationReminder min',
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: _getText('Son des notifications', 'Notification sound', 'Sonido de notificaciones'),
            subtitle: _getText('Jouer un son lors des notifications', 'Play sound for notifications', 'Reproducir sonido para notificaciones'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound_enabled', value);
            },
            enabled: _notificationsEnabled,
          ),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: _getText('Vibration', 'Vibration', 'Vibración'),
            subtitle: _getText('Vibrer lors des notifications', 'Vibrate for notifications', 'Vibrar para notificaciones'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _saveSetting('vibration_enabled', value);
            },
            enabled: _notificationsEnabled,
          ),

          Divider(color: _getBorderColor()),

          // Section Gestion des données
          _buildSectionHeader(_getText('Gestion des données', 'Data management', 'Gestión de datos')),
          _buildSwitchTile(
            icon: Icons.delete_sweep,
            title: _getText('Suppression automatique', 'Auto delete', 'Eliminación automática'),
            subtitle: _getText('Supprimer automatiquement les anciennes notifications', 'Auto delete old notifications', 'Eliminar automáticamente notificaciones antiguas'),
            value: _autoDeleteNotifications,
            onChanged: (value) {
              setState(() => _autoDeleteNotifications = value);
              _saveSetting('auto_delete_notifications', value);
            },
          ),
          if (_autoDeleteNotifications)
            _buildSliderTile(
              icon: Icons.calendar_today,
              title: _getText('Jours de conservation', 'Retention days', 'Días de retención'),
              subtitle: _getText('Supprimer les notifications après X jours', 'Delete notifications after X days', 'Eliminar notificaciones después de X días'),
              value: _autoDeleteDays.toDouble(),
              min: 7,
              max: 90,
              divisions: 83,
              onChanged: (value) {
                setState(() => _autoDeleteDays = value.toInt());
                _saveSetting('auto_delete_days', _autoDeleteDays);
              },
              enabled: true,
              valueText: '$_autoDeleteDays jours',
            ),
          _buildSwitchTile(
            icon: Icons.speed,
            title: _getText('Mode économie de données', 'Data saver mode', 'Modo ahorro de datos'),
            subtitle: _getText('Réduire la consommation des données', 'Reduce data consumption', 'Reducir consumo de datos'),
            value: _dataSaverMode,
            onChanged: (value) {
              setState(() => _dataSaverMode = value);
              _saveSetting('data_saver_mode', value);
            },
          ),

          Divider(color: _getBorderColor()),

          // Section Actions
          _buildSectionHeader(_getText('Actions', 'Actions', 'Acciones')),
          _buildActionTile(
            icon: Icons.storage,
            title: _getText('Vider le cache', 'Clear cache', 'Limpiar caché'),
            subtitle: _getText('Libérer de l\'espace de stockage', 'Free up storage space', 'Liberar espacio de almacenamiento'),
            onTap: () => _showClearCacheDialog(context),
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            title: _getText('À propos', 'About', 'Acerca de'),
            subtitle: 'CampusEvent - ${_getText('Version', 'Version', 'Versión')} 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildActionTile(
            icon: Icons.privacy_tip,
            title: _getText('Politique de confidentialité', 'Privacy policy', 'Política de privacidad'),
            subtitle: _getText('Consulter notre politique', 'View our policy', 'Ver nuestra política'),
            onTap: () => _showPrivacyDialog(context),
          ),
          _buildActionTile(
            icon: Icons.help_outline,
            title: _getText('Aide et support', 'Help & support', 'Ayuda y soporte'),
            subtitle: _getText('FAQ et contact', 'FAQ and contact', 'Preguntas frecuentes y contacto'),
            onTap: () => _showHelpDialog(context),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: Icon(Icons.language, color: AppTheme.primaryColor),
      title: Text(
        _getText('Langue', 'Language', 'Idioma'),
        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _getText('Choisir la langue de l\'application', 'Choose app language', 'Elige el idioma de la aplicación'),
        style: TextStyle(color: _getMutedTextColor(), fontSize: 12),
      ),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        items: _languages.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Row(
              children: [
                Text(entry.value['flag']!),
                const SizedBox(width: 8),
                Text(entry.value['name']!),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedLanguage = value);
            _saveSetting('language', value);
          }
        },
        underline: const SizedBox(),
        style: TextStyle(color: AppTheme.primaryColor),
        dropdownColor: _getCardColor(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: _getMutedTextColor(), fontSize: 12)),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppTheme.primaryColor,
      tileColor: _getCardColor(),
    );
  }

  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: _getMutedTextColor(), fontSize: 12)),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: TextStyle(color: AppTheme.primaryColor),
        dropdownColor: _getCardColor(),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required bool enabled,
    required String valueText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title, style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: TextStyle(color: _getMutedTextColor(), fontSize: 12)),
          trailing: Text(
            valueText,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primaryColor,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: _getMutedTextColor(), fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: _getMutedTextColor()),
      onTap: onTap,
      tileColor: _getCardColor(),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(_getText('Vider le cache', 'Clear cache', 'Limpiar caché'), style: TextStyle(color: _getTextColor())),
        content: Text(
          _getText(
            'Voulez-vous vraiment vider le cache de l\'application ?',
            'Do you really want to clear the app cache?',
            '¿Realmente quieres limpiar la caché de la aplicación?',
          ),
          style: TextStyle(color: _getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('Annuler', 'Cancel', 'Cancelar'), style: TextStyle(color: _getMutedTextColor())),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getText('Cache vidé avec succès !', 'Cache cleared successfully!', '¡Caché limpiada con éxito!')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: _getCardColor(),
        ),
        child: AboutDialog(
          applicationName: 'CampusEvent',
          applicationVersion: 'Version 1.0.0',
          applicationIcon: Icon(Icons.school, size: 48, color: AppTheme.primaryColor),
          children: [
            Text(
              _getText(
                'Application de gestion d\'événements campus',
                'Campus event management application',
                'Aplicación de gestión de eventos del campus',
              ),
              style: TextStyle(color: _getTextColor()),
            ),
            const SizedBox(height: 8),
            Text('© 2024 CampusEvent - Tous droits réservés', style: TextStyle(color: _getTextColor())),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(_getText('Politique de confidentialité', 'Privacy policy', 'Política de privacidad'), style: TextStyle(color: _getTextColor())),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Collecte des données', style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor())),
              Text(
                _getText(
                  'Nous collectons uniquement les données nécessaires au fonctionnement de l\'application.',
                  'We only collect data necessary for the operation of the application.',
                  'Solo recopilamos los datos necesarios para el funcionamiento de la aplicación.',
                ),
                style: TextStyle(color: _getTextColor()),
              ),
              const SizedBox(height: 8),
              Text('2. Utilisation des données', style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor())),
              Text(
                _getText(
                  'Vos données sont utilisées pour gérer vos inscriptions et notifications.',
                  'Your data is used to manage your registrations and notifications.',
                  'Sus datos se utilizan para gestionar sus registros y notificaciones.',
                ),
                style: TextStyle(color: _getTextColor()),
              ),
              const SizedBox(height: 8),
              Text('3. Protection des données', style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor())),
              Text(
                _getText(
                  'Toutes vos données sont stockées localement sur votre appareil.',
                  'All your data is stored locally on your device.',
                  'Todos sus datos se almacenan localmente en su dispositivo.',
                ),
                style: TextStyle(color: _getTextColor()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('Fermer', 'Close', 'Cerrar'), style: TextStyle(color: _getMutedTextColor())),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getCardColor(),
        title: Text(_getText('Aide et support', 'Help & support', 'Ayuda y soporte'), style: TextStyle(color: _getTextColor())),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@campusevent.com', style: TextStyle(color: _getTextColor())),
            const SizedBox(height: 8),
            Text('📞 Téléphone: +33 1 23 45 67 89', style: TextStyle(color: _getTextColor())),
            const SizedBox(height: 8),
            Text('🌐 Site web: www.campusevent.com', style: TextStyle(color: _getTextColor())),
            const SizedBox(height: 8),
            Text(_getText('FAQ:', 'FAQ:', 'Preguntas frecuentes:'), style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor())),
            Text(_getText('• Comment créer un événement ?', '• How to create an event?', '• ¿Cómo crear un evento?'), style: TextStyle(color: _getTextColor())),
            Text(_getText('• Comment rejoindre un club ?', '• How to join a club?', '• ¿Cómo unirse a un club?'), style: TextStyle(color: _getTextColor())),
            Text(_getText('• Comment gérer les notifications ?', '• How to manage notifications?', '• ¿Cómo gestionar las notificaciones?'), style: TextStyle(color: _getTextColor())),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getText('Fermer', 'Close', 'Cerrar'), style: TextStyle(color: _getMutedTextColor())),
          ),
        ],
      ),
    );
  }
}