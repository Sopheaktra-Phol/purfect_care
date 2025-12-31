import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/vaccination_model.dart';
import 'package:purfect_care/providers/vaccination_provider.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';

class AddVaccinationScreen extends StatefulWidget {
  final PetModel pet;
  final VaccinationModel? vaccination;

  const AddVaccinationScreen({super.key, required this.pet, this.vaccination});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final _form = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _vetNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime dateGiven = DateTime.now();
  DateTime? nextDueDate;
  bool createReminder = true;

  @override
  void initState() {
    super.initState();
    if (widget.vaccination != null) {
      _vaccineNameController.text = widget.vaccination!.vaccineName;
      _vetNameController.text = widget.vaccination!.vetName ?? '';
      _notesController.text = widget.vaccination!.notes ?? '';
      dateGiven = widget.vaccination!.dateGiven;
      nextDueDate = widget.vaccination!.nextDueDate;
      createReminder = widget.vaccination!.reminderId != null;
    }
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _vetNameController.dispose();
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
          widget.vaccination == null ? 'Add Vaccination' : 'Edit Vaccination',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.vaccination != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Vaccination'),
                    content: const Text('Are you sure you want to delete this vaccination record?'),
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
                  final vaccinationProvider = context.read<VaccinationProvider>();
                  final reminderProvider = context.read<ReminderProvider>();
                  await vaccinationProvider.deleteVaccination(
                    widget.pet.id!,
                    widget.vaccination!.id!,
                    reminderProvider,
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
              // Vaccine Name
              TextFormField(
                controller: _vaccineNameController,
                decoration: InputDecoration(
                  labelText: 'Vaccine Name *',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'e.g., Rabies, DHPP, FVRCP',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vaccine name is required' : null,
              ),
              const SizedBox(height: 16),
              // Date Given
              Container(
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
                    'Date Given *',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(dateGiven),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateGiven,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => dateGiven = date);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Next Due Date
              Container(
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
                    'Next Due Date (optional)',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  subtitle: Text(
                    nextDueDate != null
                        ? DateFormat('MMM dd, yyyy').format(nextDueDate!)
                        : 'Not set',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (nextDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => nextDueDate = null),
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: nextDueDate ?? dateGiven.add(const Duration(days: 365)),
                      firstDate: dateGiven,
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (date != null) {
                      setState(() => nextDueDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Create Reminder Checkbox
              if (nextDueDate != null)
                CheckboxListTile(
                  title: const Text(
                    'Create reminder 1 week before due date',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  value: createReminder,
                  onChanged: (value) => setState(() => createReminder = value ?? true),
                  activeColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
                ),
              const SizedBox(height: 16),
              // Vet Name
              TextFormField(
                controller: _vetNameController,
                decoration: InputDecoration(
                  labelText: 'Veterinarian/Clinic (optional)',
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
                    
                    final vaccination = VaccinationModel(
                      id: widget.vaccination?.id,
                      petId: widget.pet.id!,
                      vaccineName: _vaccineNameController.text.trim(),
                      dateGiven: dateGiven,
                      nextDueDate: nextDueDate,
                      vetName: _vetNameController.text.trim().isEmpty ? null : _vetNameController.text.trim(),
                      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      reminderId: createReminder && nextDueDate != null ? widget.vaccination?.reminderId : null,
                    );
                    
                    final vaccinationProvider = context.read<VaccinationProvider>();
                    final reminderProvider = context.read<ReminderProvider>();
                    
                    if (widget.vaccination == null) {
                      await vaccinationProvider.addVaccination(
                        vaccination,
                        createReminder && nextDueDate != null ? reminderProvider : null,
                        widget.pet,
                      );
                    } else {
                      await vaccinationProvider.updateVaccination(
                        widget.pet.id!,
                        widget.vaccination!.id!,
                        vaccination,
                        createReminder && nextDueDate != null ? reminderProvider : null,
                        widget.pet,
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
                    widget.vaccination == null ? 'Add Vaccination' : 'Update Vaccination',
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

