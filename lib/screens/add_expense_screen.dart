import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/expense_model.dart';
import 'package:purfect_care/providers/expense_provider.dart';
import 'package:purfect_care/services/image_service.dart';
import 'package:purfect_care/theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  final PetModel pet;
  final ExpenseModel? expense;

  const AddExpenseScreen({super.key, required this.pet, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _form = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String category = 'vet';
  DateTime date = DateTime.now();
  String? receiptUrl;
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      category = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _descriptionController.text = widget.expense!.description;
      date = widget.expense!.date;
      receiptUrl = widget.expense!.receiptUrl;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final uploadedUrl = await _imageService.uploadPhotoToFirebase(
          file,
          widget.pet.id!.toString(),
        );
        if (uploadedUrl != null && mounted) {
          setState(() => receiptUrl = uploadedUrl);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking receipt: $e')),
        );
      }
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
          widget.expense == null ? 'Add Expense' : 'Edit Expense',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.expense != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Expense'),
                    content: const Text('Are you sure you want to delete this expense?'),
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
                  final expenseProvider = context.read<ExpenseProvider>();
                  await expenseProvider.deleteExpense(
                    widget.pet.id!,
                    widget.expense!.id!,
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
              // Category
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category *',
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
                    value: 'vet',
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Veterinarian'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'food',
                    child: Row(
                      children: [
                        Icon(Icons.restaurant, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Food'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'grooming',
                    child: Row(
                      children: [
                        Icon(Icons.content_cut, size: 20, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Grooming'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'toys',
                    child: Row(
                      children: [
                        Icon(Icons.toys, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Toys'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'medication',
                    child: Row(
                      children: [
                        Icon(Icons.medication, size: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Medication'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Row(
                      children: [
                        Icon(Icons.category, size: 20, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Other'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixText: '\$ ',
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
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'e.g., Annual checkup, Dog food, etc.',
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
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              // Date
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
              const SizedBox(height: 16),
              // Receipt Photo
              if (receiptUrl != null)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          receiptUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() => receiptUrl = null);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickReceipt,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Add Receipt Photo (optional)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    
                    final expense = ExpenseModel(
                      id: widget.expense?.id,
                      petId: widget.pet.id!,
                      category: category,
                      amount: double.parse(_amountController.text),
                      date: date,
                      description: _descriptionController.text.trim(),
                      receiptUrl: receiptUrl,
                    );
                    
                    final expenseProvider = context.read<ExpenseProvider>();
                    if (widget.expense == null) {
                      await expenseProvider.addExpense(expense);
                    } else {
                      await expenseProvider.updateExpense(
                        widget.pet.id!,
                        widget.expense!.id!,
                        expense,
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
                    widget.expense == null ? 'Add Expense' : 'Update Expense',
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

