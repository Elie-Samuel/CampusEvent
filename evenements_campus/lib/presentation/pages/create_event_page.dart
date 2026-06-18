import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  EventType _selectedType = EventType.conference;
  bool _isEditing = false;
  Event? _editingEvent;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Event && !_isEditing) {
      _isEditing = true;
      _editingEvent = extra;
      _titleCtrl.text = extra.title;
      _descCtrl.text = extra.description;
      _locationCtrl.text = extra.location;
      _maxParticipantsCtrl.text = extra.maxParticipants.toString();
      _tagsCtrl.text = extra.tags.join(', ');
      _selectedDate = extra.date;
      _startTime = TimeOfDay.fromDateTime(extra.startTime);
      _endTime = TimeOfDay.fromDateTime(extra.endTime);
      _selectedType = extra.type;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
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
    final canAccess = _isEditing 
        ? auth.canEditEvent(_editingEvent!.organizerId)
        : auth.canCreateEvent();

    if (!canAccess) return _buildAccessDenied();

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
        _isEditing 
          ? t('Modifier', 'Edit', 'Editar')
          : t('Nouvel événement', 'New Event', 'Nuevo evento'),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: bg,
      foregroundColor: textColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (_isEditing)
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
            bottom: bottomPadding, // Padding important pour éviter la navigation
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeSelector(),
                const SizedBox(height: 20),
                _buildTextField(_titleCtrl, t('Titre *', 'Title *', 'Título *'), 
                    validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null),
                const SizedBox(height: 16),
                _buildTextField(_descCtrl, t('Description *', 'Description *', 'Descripción *'),
                    maxLines: 4,
                    validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null),
                const SizedBox(height: 16),
                _buildTextField(_locationCtrl, t('Lieu *', 'Location *', 'Ubicación *'),
                    validator: (v) => v?.isEmpty ?? true ? t('Champ requis', 'Required', 'Requerido') : null),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildTimePicker(t('Début', 'Start', 'Inicio'), _startTime, (t) => _startTime = t),
                const SizedBox(height: 16),
                _buildTimePicker(t('Fin', 'End', 'Fin'), _endTime, (t) => _endTime = t),
                const SizedBox(height: 16),
                _buildTextField(_maxParticipantsCtrl, t('Participants max *', 'Max participants *', 'Máx participantes *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return t('Champ requis', 'Required', 'Requerido');
                      if (int.tryParse(v!) == null) return t('Nombre valide', 'Valid number', 'Número válido');
                      if (int.parse(v) <= 0) return t('> 0', '> 0', '> 0');
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(_tagsCtrl, t('Tags (virgules)', 'Tags (comma)', 'Etiquetas (coma)'),
                    hint: 'tech, sport, culture'),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                // Espace supplémentaire pour être sûr
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('Type', 'Type', 'Tipo'), 
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EventType>(
              value: _selectedType,
              dropdownColor: cardBg,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: EventType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Text(type.label, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {int maxLines = 1, TextInputType? keyboardType, String? hint, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: _inputDecoration(label, hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: mutedColor),
      hintStyle: TextStyle(color: mutedColor),
      border: _outlineBorder(borderColor),
      enabledBorder: _outlineBorder(borderColor),
      focusedBorder: _outlineBorder(AppTheme.primaryColor, width: 2),
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        decoration: _inputDecoration(t('Date *', 'Date *', 'Fecha *')),
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
        decoration: _inputDecoration('$label *'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          _isEditing ? t('Mettre à jour', 'Update', 'Actualizar') : t('Créer', 'Create', 'Crear'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(t('Accès refusé', 'Access denied', 'Acceso denegado'),
            style: TextStyle(color: textColor)),
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
                  'Vous n\'avez pas les permissions nécessaires.',
                  'You don\'t have the necessary permissions.',
                  'No tienes los permisos necesarios.',
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text(t('Supprimer ?', 'Delete?', '¿Eliminar?')),
        content: Text(t('Cette action est irréversible.', 'This action is irreversible.', 'Esta acción es irreversible.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('Annuler', 'Cancel', 'Cancelar')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEvent();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t('Supprimer', 'Delete', 'Eliminar')),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent() async {
    if (_editingEvent == null) return;
    setState(() => _isSubmitting = true);
    final success = await context.read<EventViewModel>().deleteEvent(_editingEvent!.id);
    setState(() => _isSubmitting = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement supprimé'), backgroundColor: Colors.green),
      );
      context.pop();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _startTime.hour, _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _endTime.hour, _endTime.minute,
    );

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
    final evm = context.read<EventViewModel>();

    final tags = _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final maxParticipants = int.parse(_maxParticipantsCtrl.text);

    bool success = false;

    if (_isEditing && _editingEvent != null) {
      final updated = _editingEvent!.copyWith(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        location: _locationCtrl.text,
        date: _selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        type: _selectedType,
        maxParticipants: maxParticipants,
        tags: tags,
      );
      success = await evm.updateEvent(updated);
    } else {
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
        type: _selectedType,
        maxParticipants: maxParticipants,
        currentParticipants: 0,
        tags: tags,
      );
      success = await evm.createEvent(event);
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing 
              ? t('Événement modifié !', 'Event updated!', '¡Evento actualizado!')
              : t('Événement créé !', 'Event created!', '¡Evento creado!')),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted && evm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(evm.errorMessage!), backgroundColor: Colors.red),
      );
    }
  }
}