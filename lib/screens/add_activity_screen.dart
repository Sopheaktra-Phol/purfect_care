import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/activity_model.dart';
import 'package:purfect_care/providers/activity_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';

class AddActivityScreen extends StatefulWidget {
  final PetModel pet;
  final ActivityModel? activity;

  const AddActivityScreen({super.key, required this.pet, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _form = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  
  String type = 'walk';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      type = widget.activity!.type;
      _durationController.text = widget.activity!.duration.toString();
      _distanceController.text = widget.activity!.distance?.toString() ?? '';
      _notesController.text = widget.activity!.notes ?? '';
      date = widget.activity!.date;
      time = TimeOfDay.fromDateTime(widget.activity!.date);
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.accentOrange,
        elevation: 0,
        title: Text(
          widget.activity == null ? 'Add Activity' : 'Edit Activity',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.activity != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Activity'),
                    content: const Text('Are you sure you want to delete this activity?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  final activityProvider = context.read<ActivityProvider>();
                  await activityProvider.deleteActivity(
                    widget.pet.id!,
                    widget.activity!.id!,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              // Activity Type
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(
                  labelText: 'Activity Type *',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'walk',
                    child: Row(
                      children: [
                        Icon(Icons.directions_walk, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Walk'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        Icon(Icons.sports_tennis, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Play'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'exercise',
                    child: Row(
                      children: [
                        Icon(Icons.fitness_center, size: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Exercise'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'training',
                    child: Row(
                      children: [
                        Icon(Icons.school, size: 20, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Training'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, size: 20, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Other'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => type = value);
                    // Clear distance if not a walk
                    if (value != 'walk') {
                      _distanceController.clear();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              // Duration
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes) *',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Duration is required';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Distance (only for walks)
              if (type == 'walk')
                TextFormField(
                  controller: _distanceController,
                  decoration: InputDecoration(
                    labelText: 'Distance (miles) - optional',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final distance = double.tryParse(value);
                      if (distance == null || distance < 0) {
                        return 'Please enter a valid distance';
                      }
                    }
                    return null;
                  },
                ),
              if (type == 'walk') const SizedBox(height: 16),
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(date),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (selectedDate != null) {
                            setState(() => date = selectedDate);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          'Time',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Text(
                          time.format(context),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (selectedTime != null) {
                            setState(() => time = selectedTime);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'Add any additional notes...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  filled: true,
                  fillColor: isDark ? theme.colorScheme.surfaceVariant : const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    
                    // Combine date and time
                    final activityDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                    
                    final activity = ActivityModel(
                      id: widget.activity?.id,
                      petId: widget.pet.id!,
                      type: type,
                      duration: int.parse(_durationController.text),
                      date: activityDateTime,
                      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      distance: _distanceController.text.trim().isEmpty 
                          ? null 
                          : double.tryParse(_distanceController.text.trim()),
                    );
                    
                    final activityProvider = context.read<ActivityProvider>();
                    if (widget.activity == null) {
                      await activityProvider.addActivity(activity);
                    } else {
                      await activityProvider.updateActivity(
                        widget.pet.id!,
                        widget.activity!.id!,
                        activity,
                      );
                    }
                    
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                    foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.activity == null ? 'Add Activity' : 'Update Activity',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

