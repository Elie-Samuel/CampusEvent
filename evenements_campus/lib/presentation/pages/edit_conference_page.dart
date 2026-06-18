import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class EditConferencePage extends StatefulWidget {
  final Event event;
  const EditConferencePage({super.key, required this.event});

  @override
  State<EditConferencePage> createState() => _EditConferencePageState();
}

class _EditConferencePageState extends State<EditConferencePage> {
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
    _loadSettings();
    // Remplir les champs avec les données existantes
    _titleCtrl.text = widget.event.title;
    _descCtrl.text = widget.event.description;
    _locationCtrl.text = widget.event.location;
    _maxParticipantsCtrl.text = widget.event.maxParticipants.toString();
    _selectedDate = widget.event.date;
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);

    // Extraire le nom du conférencier des tags
    final speakerTag = widget.event.tags.firstWhere(
      (t) => t.startsWith('speaker:') || t.startsWith('conférencier:'),
      orElse: () => '',
    );
    if (speakerTag.isNotEmpty) {
      final parts = speakerTag.split(':');
      if (parts.length > 1) {
        _speakerCtrl.text = parts.sublist(1).join(':').trim();
      }
    }

    // Récupérer les tags sans le tag du conférencier
    final otherTags = widget.event.tags
        .where((t) => !t.startsWith('speaker:') && !t.startsWith('conférencier:'))
        .join(', ');
    _tagsCtrl.text = otherTags;
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
      case 'en':
        return en;
      case 'es':
        return es;
      default:
        return fr;
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

    // Vérifier si l'utilisateur peut modifier cette conférence
    if (!auth.canEditEvent(widget.event.organizerId)) {
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
        t('Modifier la conférence', 'Edit Conference', 'Editar Conferencia'),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: _confirmDelete,
        ),
      ],
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
            bottom: bottomPadding,
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

                _buildActionButtons(),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: mutedColor,
              side: BorderSide(color: borderColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t('Annuler', 'Cancel', 'Cancelar'),
              style: TextStyle(color: mutedColor, fontSize: 16),
            ),
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
              elevation: 0,
            ),
            child: Text(
              t('Enregistrer', 'Save', 'Guardar'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
                  'Vous n\'avez pas la permission de modifier cette conférence.',
                  'You do not have permission to edit this conference.',
                  'No tienes permiso para editar esta conferencia.',
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(
          t('Supprimer la conférence ?', 'Delete conference?', '¿Eliminar conferencia?'),
          style: TextStyle(color: textColor),
        ),
        content: Text(
          t('Cette action est irréversible.', 'This action is irreversible.', 'Esta acción es irreversible.'),
          style: TextStyle(color: mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              t('Annuler', 'Cancel', 'Cancelar'),
              style: TextStyle(color: mutedColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEvent();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              t('Supprimer', 'Delete', 'Eliminar'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent() async {
    setState(() => _isSubmitting = true);
    final success = await context.read<EventViewModel>().deleteEvent(widget.event.id);
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Conférence supprimée', 'Conference deleted', 'Conferencia eliminada')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
      context.pop(); // Retour à la page des conférences
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Erreur lors de la suppression', 'Error deleting', 'Error al eliminar')),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    final eventViewModel = context.read<EventViewModel>();

    // Construire la liste des tags
    List<String> tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Ajouter le conférencier aux tags s'il est spécifié
    if (_speakerCtrl.text.isNotEmpty) {
      tags.add('speaker: ${_speakerCtrl.text}');
    }

    final updatedEvent = widget.event.copyWith(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      location: _locationCtrl.text,
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
      maxParticipants: int.parse(_maxParticipantsCtrl.text),
      tags: tags,
    );

    final success = await eventViewModel.updateEvent(updatedEvent);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Conférence modifiée !', 'Conference updated!', '¡Conferencia actualizada!')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
      context.pop(); // Retour à la page des conférences
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