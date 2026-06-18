import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class CreateConferencePage extends StatefulWidget {
  const CreateConferencePage({super.key});

  @override
  State<CreateConferencePage> createState() => _CreateConferencePageState();
}

class _CreateConferencePageState extends State<CreateConferencePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _speakerCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isSubmitting = false;
  bool _isDarkMode = false;
  String _locale = 'fr';

  @override
  void initState() {
    super.initState();
    _initDefaultTimes();
    _loadSettings();
  }

  void _initDefaultTimes() {
    final now = DateTime.now();
    _startTime = TimeOfDay(
      hour: now.hour.clamp(8, 22),
      minute: now.minute,
    );
    _endTime = TimeOfDay(
      hour: (_startTime.hour + 1).clamp(8, 23),
      minute: _startTime.minute,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode_enabled') ?? false;
      _locale = prefs.getString('language') ?? 'fr';
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _speakerCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  String t(String fr, String en, String es) {
    switch (_locale) {
      case 'en': return en;
      case 'es': return es;
      default: return fr;
    }
  }

  Color get bg => _isDarkMode ? AppTheme.darkBackground : Colors.white;
  Color get cardBg => _isDarkMode ? AppTheme.darkCard : Colors.white;
  Color get textColor => _isDarkMode ? AppTheme.darkText : Colors.black;
  Color get mutedColor => _isDarkMode ? AppTheme.darkTextMuted : AppTheme.textMuted;
  Color get borderColor => _isDarkMode ? AppTheme.darkBorder : AppTheme.borderLight;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    // Vérifier si l'utilisateur peut créer une conférence
    if (!auth.canCreateConference()) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _buildForm(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        t('Créer une conférence', 'Create Conference', 'Crear Conferencia'),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: bg,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul du padding bas pour éviter la navigation
        final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomPadding, // Padding important pour éviter la navigation
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  _titleCtrl,
                  t('Titre *', 'Title *', 'Título *'),
                  hint: t('Ex: Conférence sur l\'IA', 'Ex: AI Conference', 'Ej: Conferencia IA'),
                  icon: Icons.title,
                  validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _descCtrl,
                  t('Description *', 'Description *', 'Descripción *'),
                  hint: t('Décrivez le contenu...', 'Describe the content...', 'Describe el contenido...'),
                  icon: Icons.description,
                  maxLines: 5,
                  validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _locationCtrl,
                  t('Lieu *', 'Location *', 'Ubicación *'),
                  hint: t('Salle, amphithéâtre...', 'Room, auditorium...', 'Sala, auditorio...'),
                  icon: Icons.location_on,
                  validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _speakerCtrl,
                  t('Conférencier', 'Speaker', 'Conferencista'),
                  hint: t('Nom du conférencier', 'Speaker name', 'Nombre del conferencista'),
                  icon: Icons.mic,
                ),
                const SizedBox(height: 16),

                _buildDatePicker(),
                const SizedBox(height: 16),

                _buildTimePicker(
                  t('Début *', 'Start *', 'Inicio *'),
                  _startTime,
                  (t) => setState(() => _startTime = t),
                ),
                const SizedBox(height: 16),

                _buildTimePicker(
                  t('Fin *', 'End *', 'Fin *'),
                  _endTime,
                  (t) => setState(() => _endTime = t),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _maxParticipantsCtrl,
                  t('Participants max *', 'Max participants *', 'Máx participantes *'),
                  hint: '50',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return t('Champ requis', 'Required', 'Requerido');
                    if (int.tryParse(v!) == null) return t('Nombre valide', 'Valid number', 'Número válido');
                    if (int.parse(v) <= 0) return t('> 0', '> 0', '> 0');
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _tagsCtrl,
                  t('Tags (virgules)', 'Tags (comma)', 'Etiquetas (coma)'),
                  hint: 'tech, innovation, IA',
                  icon: Icons.label,
                ),
                const SizedBox(height: 24),

                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: mutedColor),
        labelStyle: TextStyle(color: mutedColor),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
        border: _outlineBorder(borderColor),
        enabledBorder: _outlineBorder(borderColor),
        focusedBorder: _outlineBorder(AppTheme.primaryColor, width: 2),
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: t('Date *', 'Date *', 'Fecha *'),
          labelStyle: TextStyle(color: mutedColor),
          border: _outlineBorder(borderColor),
          enabledBorder: _outlineBorder(borderColor),
          focusedBorder: _outlineBorder(AppTheme.primaryColor, width: 2),
          filled: true,
          fillColor: cardBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay time, void Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChanged(t);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: mutedColor),
          border: _outlineBorder(borderColor),
          enabledBorder: _outlineBorder(borderColor),
          focusedBorder: _outlineBorder(AppTheme.primaryColor, width: 2),
          filled: true,
          fillColor: cardBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              time.format(context),
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          t('Créer la conférence', 'Create Conference', 'Crear Conferencia'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          t('Accès refusé', 'Access denied', 'Acceso denegado'),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.red.withAlpha(80)),
              const SizedBox(height: 24),
              Text(
                t(
                  'Vous n\'avez pas la permission de créer une conférence.',
                  'You do not have permission to create a conference.',
                  'No tienes permiso para crear una conferencia.',
                ),
                style: TextStyle(fontSize: 16, color: mutedColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(t('Retour', 'Back', 'Volver')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Vérifier que l'heure de fin est après l'heure de début
    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Fin après début', 'End after start', 'Fin después de inicio')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthViewModel>();
    final eventViewModel = context.read<EventViewModel>();

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Ajouter le conférencier aux tags s'il est spécifié
    if (_speakerCtrl.text.isNotEmpty) {
      tags.add('speaker: ${_speakerCtrl.text}');
    }

    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text,
      description: _descCtrl.text,
      location: _locationCtrl.text,
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
      organizerId: auth.currentUser!.id,
      organizerName: auth.currentUser!.fullName,
      type: EventType.conference,
      maxParticipants: int.parse(_maxParticipantsCtrl.text),
      currentParticipants: 0,
      tags: tags,
    );

    final success = await eventViewModel.createEvent(event);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Conférence créée !', 'Conference created!', '¡Conferencia creada!')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted && eventViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(eventViewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}