import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/milestone_model.dart';
import 'package:purfect_care/providers/milestone_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';

class AddMilestoneScreen extends StatefulWidget {
  final PetModel pet;
  final MilestoneModel? milestone;

  const AddMilestoneScreen({super.key, required this.pet, this.milestone});

  @override
  State<AddMilestoneScreen> createState() => _AddMilestoneScreenState();
}

class _AddMilestoneScreenState extends State<AddMilestoneScreen> {
  final _form = GlobalKey<FormState>();
  String title = '';
  DateTime date = DateTime.now();
  String type = 'custom';
  String? notes;

  @override
  void initState() {
    super.initState();
    if (widget.milestone != null) {
      title = widget.milestone!.title;
      date = widget.milestone!.date;
      type = widget.milestone!.type;
      notes = widget.milestone!.notes;
    } else {
      // Set default title based on type if creating new
      title = 'Custom Milestone';
    }
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
          widget.milestone == null ? 'Add Milestone' : 'Edit Milestone',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.milestone != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Milestone'),
                    content: const Text('Are you sure you want to delete this milestone?'),
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
                  final provider = context.read<MilestoneProvider>();
                  await provider.deleteMilestone(widget.pet.id!, widget.milestone!.id!);
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
              // Milestone Type Dropdown
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(
                  labelText: 'Milestone Type',
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
                    value: 'birthday',
                    child: Row(
                      children: [
                        Icon(Icons.cake, size: 20, color: Colors.pink),
                        SizedBox(width: 8),
                        Text('Birthday'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'adoption',
                    child: Row(
                      children: [
                        Icon(Icons.home, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Adoption Anniversary'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Custom Milestone'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      type = value;
                      // Update default title based on type
                      if (widget.milestone == null) {
                        switch (value) {
                          case 'birthday':
                            title = 'Birthday';
                            break;
                          case 'adoption':
                            title = 'Adoption Anniversary';
                            break;
                          default:
                            title = 'Custom Milestone';
                        }
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Title Field
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(
                  labelText: 'Title',
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
                onSaved: (v) => title = v?.trim() ?? '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              // Date Picker
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
                    final dt = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(DateTime.now().year + 10),
                    );
                    if (dt != null) {
                      setState(() => date = dt);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Notes Field
              TextFormField(
                initialValue: notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'Add any additional notes about this milestone...',
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
                onSaved: (v) => notes = v?.trim(),
              ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    _form.currentState!.save();
                    
                    final milestone = MilestoneModel(
                      id: widget.milestone?.id,
                      petId: widget.pet.id!,
                      title: title,
                      date: date,
                      type: type,
                      notes: notes,
                    );
                    
                    final provider = context.read<MilestoneProvider>();
                    if (widget.milestone == null) {
                      await provider.addMilestone(milestone);
                    } else {
                      await provider.updateMilestone(widget.pet.id!, widget.milestone!.id!, milestone);
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
                    widget.milestone == null ? 'Add Milestone' : 'Update Milestone',
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

