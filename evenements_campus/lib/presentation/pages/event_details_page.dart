import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../domain/entities/event.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';

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
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  EventType _selectedType = EventType.conference;
  
  bool _isEditing = false;
  Event? _editingEvent;

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    
    // Vérifier si l'utilisateur peut créer/modifier un événement
    if (_isEditing) {
      if (!auth.canEditEvent(_editingEvent!.organizerId)) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Accès refusé'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: const Center(
            child: Text('Vous n\'avez pas la permission de modifier cet événement.'),
          ),
        );
      }
    } else {
      if (!auth.canCreateEvent()) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Accès refusé'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: const Center(
            child: Text('Vous n\'avez pas la permission de créer des événements.'),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier l\'événement' : 'Créer un événement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type d'événement
              const Text('Type d\'événement', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<EventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),
              
              // Titre
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),
              
              // Lieu
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Lieu requis' : null,
              ),
              const SizedBox(height: 16),
              
              // Date
              InkWell(
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
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Heure de début
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _startTime);
                  if (time != null) setState(() => _startTime = time);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Heure de début',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  child: Text(_startTime.format(context)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Heure de fin
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _endTime);
                  if (time != null) setState(() => _endTime = time);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Heure de fin',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  child: Text(_endTime.format(context)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nombre max de participants
              TextFormField(
                controller: _maxParticipantsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre maximum de participants',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nombre requis';
                  if (int.tryParse(v) == null) return 'Nombre valide requis';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Tags
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags (séparés par des virgules)',
                  hintText: 'tech, sport, culture',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isEditing ? 'Mettre à jour' : 'Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthViewModel>();
    final eventViewModel = context.read<EventViewModel>();
    
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
    
    final tags = _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    
    if (_isEditing && _editingEvent != null) {
      // TODO: Implémenter la mise à jour de l'événement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fonctionnalité de modification à venir')),
      );
    } else {
      // Création
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
        maxParticipants: int.parse(_maxParticipantsCtrl.text),
        currentParticipants: 0,
        tags: tags,
      );
      
      final success = await eventViewModel.createEvent(event);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement créé avec succès !')),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(eventViewModel.errorMessage ?? 'Erreur lors de la création')),
        );
      }
    }
  }
}