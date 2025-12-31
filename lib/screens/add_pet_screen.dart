import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
import 'package:purfect_care/providers/auth_provider.dart';
import 'package:purfect_care/services/image_service.dart';
import 'package:purfect_care/services/breed_api_service.dart';
import 'package:purfect_care/widgets/safe_image.dart';

class AddPetScreen extends StatefulWidget {
  final PetModel? pet;

  const AddPetScreen({super.key, this.pet});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _form = GlobalKey<FormState>();
  final _breedController = TextEditingController();
  final _speciesOtherController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();
  
  String name = '';
  String species = 'Dog';
  String gender = 'Male';
  int age = 0;
  String breed = '';
  String? photoPath;
  String? notes;
  String weight = '';
  String height = '';
  String color = '';
  DateTime? birthDate;
  DateTime? adoptionDate;

  final ImageService _img = ImageService();
  final BreedApiService _breedApi = BreedApiService();
  List<String> _availableBreeds = [];
  bool _isLoadingBreeds = false;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      name = widget.pet!.name;
      final petSpecies = widget.pet!.species;
      if (petSpecies != 'Dog' && petSpecies != 'Cat') {
        species = 'Other';
        _speciesOtherController.text = petSpecies;
      } else {
        species = petSpecies;
      }
      gender = widget.pet!.gender;
      age = widget.pet!.age;
      breed = widget.pet!.breed;
      photoPath = widget.pet!.photoPath;
      notes = widget.pet!.notes;
      weight = widget.pet!.weight ?? '';
      height = widget.pet!.height ?? '';
      color = widget.pet!.color ?? '';
      birthDate = widget.pet!.birthDate;
      adoptionDate = widget.pet!.adoptionDate;
      _breedController.text = breed;
      _notesController.text = notes ?? '';
      _weightController.text = weight;
      _heightController.text = height;
      _colorController.text = color;
    }
    _loadBreeds();
  }

  @override
  void dispose() {
    _breedController.dispose();
    _speciesOtherController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBreeds() async {
    if (species != 'Dog' && species != 'Cat') return;
    
    setState(() => _isLoadingBreeds = true);
    try {
      final breeds = species == 'Dog'
          ? await _breedApi.getDogBreeds()
          : await _breedApi.getCatBreeds();
      if (mounted) {
        setState(() {
          _availableBreeds = breeds;
          _isLoadingBreeds = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBreeds = false);
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
        backgroundColor: isDark ? theme.colorScheme.surface : const Color(0xFFFB930B),
        elevation: 0,
        title: Text(
          widget.pet == null ? 'Add Pet' : 'Edit Pet',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? theme.colorScheme.onSurface : Colors.white),
      ),
      body: Form(
          key: _form,
        child: CustomScrollView(
          slivers: [
            // Large photo at top
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 350,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                onTap: () async {
                  if (widget.pet != null && photoPath != null && photoPath != widget.pet!.photoPath) {
                    await _img.deleteImage(photoPath);
                  }
                  final f = await _img.pickImageFromGallery();
                  if (f != null) {
                    if (widget.pet != null && widget.pet!.photoPath != null && widget.pet!.photoPath != f.path) {
                      await _img.deleteImage(widget.pet!.photoPath);
                    }
                    setState(() => photoPath = f.path);
                  }
                },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SafeImage(
                  imagePath: photoPath,
                        fit: BoxFit.cover,
                        placeholder: Container(
                          color: theme.colorScheme.surfaceVariant ?? Colors.grey[300],
                          child: Icon(
                            Icons.pets,
                            size: 100,
                            color: theme.colorScheme.onSurfaceVariant ?? Colors.grey,
                ),
              ),
                      ),
                      // Overlay with "Tap to add photo" text
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white, size: 48),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                ),
                              ),
                ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content section
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header with Name, Breed, and Gender
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant ?? theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? theme.colorScheme.outline : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name field
              TextFormField(
                                    initialValue: name,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Pet Name',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                    ),
                                    onSaved: (v) => name = v?.trim() ?? '',
                                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
                                  const SizedBox(height: 12),
                                  // Breed field
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _availableBreeds.take(10);
                  }
                  final filtered = _breedApi.filterBreeds(
                    _availableBreeds,
                    textEditingValue.text,
                  );
                  return filtered.take(20);
                },
                onSelected: (String selection) {
                  _breedController.text = selection;
                  breed = selection;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  if (_breedController.text.isNotEmpty && 
                      textEditingController.text != _breedController.text) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      textEditingController.text = _breedController.text;
                    });
                  }
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface,
                                        ),
                    decoration: InputDecoration(
                                          hintText: 'Breed',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      suffixIcon: _isLoadingBreeds
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      breed = value;
                      _breedController.text = value;
                    },
                    onSaved: (v) => breed = v ?? '',
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      option,
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Gender button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  gender = gender == 'Male' ? 'Female' : 'Male';
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: gender == 'Female' 
                                      ? const Color(0xFFFFB6C1) // Pink for female
                                      : const Color(0xFFADD8E6), // Light blue for male
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  gender == 'Female' ? Icons.female : Icons.male,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // "About" Section
                      Row(
                        children: [
                          Icon(Icons.pets, color: theme.colorScheme.onSurface, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'About',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats boxes (Age, Weight, Height, Breed)
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Age',
                              icon: Icons.cake,
                              iconColor: const Color(0xFFFB930B), // Orange
                              child: TextFormField(
                                initialValue: age > 0 ? age.toString() : '',
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                textAlign: TextAlign.center,
                                onSaved: (v) => age = int.tryParse(v ?? '0') ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Weight',
                              icon: Icons.scale,
                              iconColor: Colors.green,
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                textAlign: TextAlign.center,
                                onSaved: (v) => weight = v ?? '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Height',
                              icon: Icons.straighten,
                              iconColor: Colors.blue,
                              child: TextFormField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                textAlign: TextAlign.center,
                                onSaved: (v) => height = v ?? '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Breed',
                              icon: Icons.pets,
                              iconColor: Colors.purple,
                              child: TextFormField(
                                controller: _colorController,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                textAlign: TextAlign.center,
                                onSaved: (v) => color = v ?? '',
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Personal Note Section
                      Row(
                        children: [
                          Icon(Icons.note, color: theme.colorScheme.onSurface, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Personal Note',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Personal Note
              TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a personal note about your pet...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
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
                              color: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                onSaved: (v) => notes = v,
              ),
                      
                      const SizedBox(height: 16),
                      
                      // Birth Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.cake, color: theme.colorScheme.onSurface),
                        title: Text(
                          'Birth Date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          birthDate != null
                              ? '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'
                              : 'Not set (optional)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(Icons.calendar_today, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => birthDate = date);
                            // Calculate age from birth date
                            final now = DateTime.now();
                            final months = (now.year - date.year) * 12 + (now.month - date.month);
                            age = months.clamp(0, 999);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Adoption Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.home, color: theme.colorScheme.onSurface),
                        title: Text(
                          'Adoption Date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          adoptionDate != null
                              ? '${adoptionDate!.day}/${adoptionDate!.month}/${adoptionDate!.year}'
                              : 'Not set (optional)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Icon(Icons.calendar_today, color: theme.colorScheme.onSurfaceVariant),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: adoptionDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => adoptionDate = date);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Species Section
                      Row(
                        children: [
                          Icon(Icons.category, color: theme.colorScheme.onSurface, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Species',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Species dropdown
                      DropdownButtonFormField(
                        value: species,
                        items: const [
                          DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                          DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) {
                          setState(() {
                            species = v as String;
                            if (species == 'Other') {
                              _speciesOtherController.text = '';
                            } else {
                              _speciesOtherController.text = '';
                              _loadBreeds();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select species',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
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
                              color: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
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
                      
                      if (species == 'Other')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFormField(
                            controller: _speciesOtherController,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Bird, Rabbit, Hamster',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
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
                                  color: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onSaved: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                species = v.trim();
                              }
                            },
                            validator: (v) {
                              if (species == 'Other' && (v == null || v.trim().isEmpty)) {
                                return 'Please specify the species';
                              }
                              return null;
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  _form.currentState!.save();
                  
                  // Check if user is authenticated
                  final authProvider = context.read<AuthProvider>();
                  if (!authProvider.isAuthenticated) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to add pets.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  
                  // Upload pet profile photo to Firebase Storage if a new photo was selected
                  String? finalPhotoPath = photoPath;
                  final currentPhotoPath = photoPath;
                  if (currentPhotoPath != null && currentPhotoPath.isNotEmpty) {
                    // Check if it's already a Firebase Storage URL (starts with http)
                    if (!currentPhotoPath.startsWith('http')) {
                      // It's a local file, upload it to Firebase Storage
                      print('📤 Uploading pet profile photo to Firebase Storage...');
                      
                      // For new pets, use 'profile' as petId, for existing pets use their ID
                      final petIdForUpload = widget.pet?.id?.toString() ?? 'profile';
                      final uploadedUrl = await _img.uploadPhotoToFirebase(File(currentPhotoPath), petIdForUpload);
                      
                      if (uploadedUrl != null) {
                        print('✅ Pet profile photo uploaded: $uploadedUrl');
                        finalPhotoPath = uploadedUrl;
                        // Delete local file after successful upload
                        await _img.deleteImage(currentPhotoPath);
                      } else {
                        print('⚠️ Failed to upload pet profile photo, keeping local path');
                        // Keep local path as fallback
                      }
                      
                      // Delete old photo if updating
                      if (widget.pet != null && widget.pet!.photoPath != null && widget.pet!.photoPath != photoPath) {
                        // Check if old photo is a Firebase Storage URL
                        if (widget.pet!.photoPath!.startsWith('http')) {
                          await _img.deletePhotoFromFirebase(widget.pet!.photoPath!);
                        } else {
                          await _img.deleteImage(widget.pet!.photoPath!);
                        }
                      }
                    } else {
                      // Already a Firebase Storage URL, just delete old one if different
                      if (widget.pet != null && widget.pet!.photoPath != null && widget.pet!.photoPath != photoPath) {
                        await _img.deletePhotoFromFirebase(widget.pet!.photoPath!);
                      }
                    }
                  } else if (widget.pet != null && widget.pet!.photoPath != null) {
                    // Photo was removed, delete old one
                    if (widget.pet!.photoPath!.startsWith('http')) {
                      await _img.deletePhotoFromFirebase(widget.pet!.photoPath!);
                    } else {
                      await _img.deleteImage(widget.pet!.photoPath!);
                    }
                  }
                  
                  // If pet was just created, we need to re-upload the photo with the correct petId
                  // This will be handled after the pet is saved and we have the pet ID
                  
                  final pet = PetModel(
                    id: widget.pet?.id,
                    name: name,
                    species: species,
                    gender: gender,
                    age: age,
                    breed: breed,
                    photoPath: finalPhotoPath,
                    notes: notes,
                    weight: weight.isEmpty ? null : weight,
                    height: height.isEmpty ? null : height,
                    color: color.isEmpty ? null : color,
                    birthDate: birthDate,
                    adoptionDate: adoptionDate,
                  );
                  print('📝 Pet model created with photoPath: ${pet.photoPath}');
                  print('📝 finalPhotoPath value: $finalPhotoPath');
                  final provider = context.read<PetProvider>();
                  
                  // Show loading indicator with proper context reference
                  if (!mounted) return;
                  final navigator = Navigator.of(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  try {
                    print('📝 Starting to save pet...');
                    print('📝 Pet data: name=${pet.name}, species=${pet.species}, photoPath=${pet.photoPath}');
                    
                    if (widget.pet == null) {
                      await provider.addPet(pet);
                      print('📝 addPet completed, error: ${provider.errorMessage}');
                      
                      // If pet was just created and we have a local photo path, upload it now with the correct petId
                      final currentFinalPhotoPathForReupload = finalPhotoPath;
                      if (pet.id != null && currentFinalPhotoPathForReupload != null && !currentFinalPhotoPathForReupload.startsWith('http')) {
                        print('📤 Re-uploading pet profile photo with correct pet ID: ${pet.id}');
                        final uploadedUrl = await _img.uploadPhotoToFirebase(File(currentFinalPhotoPathForReupload), pet.id.toString());
                        if (uploadedUrl != null) {
                          print('✅ Pet profile photo re-uploaded: $uploadedUrl');
                          // Update the pet with the Firebase Storage URL
                          pet.photoPath = uploadedUrl;
                          await provider.updatePet(pet.id!, pet);
                          await _img.deleteImage(currentFinalPhotoPathForReupload);
                        }
                      }
                    } else {
                      // Updating existing pet
                      if (widget.pet?.id != null) {
                        await provider.updatePet(widget.pet!.id!, pet);
                        print('📝 updatePet completed, error: ${provider.errorMessage}');
                      } else {
                        print('⚠️ Cannot update pet: widget.pet.id is null');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Pet ID is missing. Please try again.'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                    }
                    
                    if (!mounted) return;
                    
                    // Close loading dialog FIRST
                    navigator.pop();
                    print('📝 Loading dialog closed');
                    
                    // Check for errors AFTER closing dialog
                    if (provider.errorMessage != null) {
                      print('❌ Provider has error: ${provider.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage!),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return; // Don't navigate if there's an error
                    }
                    
                    print('✅ Success! Navigating back...');
                    // Success - navigate back
                    navigator.pop();
                  } catch (e, stackTrace) {
                    print('❌ Exception in add pet screen: $e');
                    print('❌ Stack trace: $stackTrace');
                    
                    if (!mounted) return;
                    
                    // Always close loading dialog, even on error
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                    
                    // Show error message
                    final errorMsg = provider.errorMessage ?? 
                        (e.toString().contains('permission') 
                            ? 'Permission denied. Please check Firebase security rules.'
                            : 'Failed to save pet: ${e.toString()}');
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? theme.colorScheme.primary : const Color(0xFFFB930B),
                            foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? theme.colorScheme.outline : Colors.black,
                                width: 1.5,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stat Box Widget
class _StatBox extends StatelessWidget {
  final String label;
  final Widget child;
  final IconData icon;
  final Color iconColor;

  const _StatBox({
    required this.label,
    required this.child,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.surfaceVariant?.withOpacity(0.5) 
            : const Color(0xFFFFE5D4).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in white circular background
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Text field below
          child,
        ],
      ),
    );
  }
}
