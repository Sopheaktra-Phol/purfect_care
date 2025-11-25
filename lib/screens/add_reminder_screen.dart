import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/reminder_model.dart';
import 'package:purfect_care/providers/reminder_provider.dart';
import 'package:purfect_care/services/notification_service.dart';

class AddReminderScreen extends StatefulWidget {
  final PetModel pet;
  final ReminderModel? reminder;
  const AddReminderScreen({super.key, required this.pet, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _form = GlobalKey<FormState>();
  
  void _showSuccessDialog(BuildContext context, {required String title, required String message, required IconData icon}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with animated background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8771).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: const Color(0xFF2E8771),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close add reminder screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB930B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
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
  String title = 'Feed';
  String customTitle = '';
  DateTime dateTime = DateTime.now().add(const Duration(hours: 1));
  String repeat = 'none';
  bool _isCompleted = false; // Track completion state

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      // Check if it's a custom title (not in the standard list)
      final standardTitles = ['Feed', 'Walk', 'Vet', 'Groom'];
      if (standardTitles.contains(widget.reminder!.title)) {
      title = widget.reminder!.title;
      } else {
        title = 'Custom';
        customTitle = widget.reminder!.title;
      }
      dateTime = widget.reminder!.time;
      repeat = widget.reminder!.repeat;
      // Preserve isCompleted state when editing
      _isCompleted = widget.reminder!.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background - matching theme
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange - matching theme
        elevation: 0,
        title: Text(
          widget.reminder == null ? 'Add Reminder' : 'Edit Reminder',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.reminder != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    title: const Text(
                      'Delete Reminder',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this reminder?',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                final provider = context.read<ReminderProvider>();
                await provider.deleteReminder(widget.reminder!.id!);
                if (!mounted) return;
                Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task Type Dropdown
              DropdownButtonFormField<String>(
                value: title,
                decoration: InputDecoration(
                  labelText: 'Task Type',
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFB930B), width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Feed', child: Text('Feed', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'Walk', child: Text('Walk', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'Vet', child: Text('Vet Visit', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'Groom', child: Text('Groom', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'Custom', child: Text('Custom', style: TextStyle(fontFamily: 'Poppins'))),
                ],
                onChanged: (v) => setState(() => title = v as String),
              ),
              const SizedBox(height: 16),
              // Custom Title Field
              if (title == 'Custom')
                TextFormField(
                  initialValue: customTitle,
                  style: const TextStyle(fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    labelText: 'Custom Task Name',
                    labelStyle: const TextStyle(fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFB930B), width: 2),
                    ),
                  ),
                  onChanged: (v) => customTitle = v,
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              if (title == 'Custom') const SizedBox(height: 16),
              // Date & Time Picker
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: InkWell(
                  onTap: () => _showDateTimePicker(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFFFB930B)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date & Time',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.yMd().add_jm().format(dateTime),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
              ),
              ),
              const SizedBox(height: 16),
              // Repeat Interval Dropdown
              DropdownButtonFormField<String>(
                value: repeat,
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  labelStyle: const TextStyle(fontFamily: 'Poppins'),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFB930B), width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('One-time', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'daily', child: Text('Daily', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly', style: TextStyle(fontFamily: 'Poppins'))),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly', style: TextStyle(fontFamily: 'Poppins'))),
                ],
                onChanged: (v) => setState(() => repeat = v as String),
              ),
              const SizedBox(height: 16),
              // Save Button
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  final reminderTitle = title == 'Custom' ? customTitle : title;
                  final r = ReminderModel(
                    id: widget.reminder?.id,
                    petId: widget.pet.id!,
                    title: reminderTitle,
                    time: dateTime,
                    repeat: repeat,
                    notificationId: widget.reminder?.notificationId,
                    isCompleted: widget.reminder != null ? _isCompleted : false,
                  );
                  final provider = context.read<ReminderProvider>();
                  if (widget.reminder == null) {
                    await provider.addReminder(r, widget.pet);
                    if (mounted) {
                      _showSuccessDialog(
                        context,
                        title: 'Task Created!',
                        message: 'Your reminder has been scheduled for ${DateFormat.yMd().add_jm().format(dateTime)}',
                        icon: Icons.check_circle,
                      );
                    }
                  } else {
                    await provider.updateReminder(widget.reminder!.id!, r, widget.pet);
                    if (mounted) {
                      _showSuccessDialog(
                        context,
                        title: 'Task Updated!',
                        message: 'Your reminder has been updated successfully',
                        icon: Icons.check_circle,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFB930B), // Orange
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Reminder',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    DateTime tempDate = dateTime;
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with Done button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() => dateTime = tempDate);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Date and Time Picker
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: dateTime,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime(DateTime.now().year + 5),
                    use24hFormat: false,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
