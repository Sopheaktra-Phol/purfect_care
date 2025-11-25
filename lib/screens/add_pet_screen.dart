import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/providers/pet_provider.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F5), // Light beige background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFB930B), // Orange
        elevation: 0,
        title: Text(
          widget.pet == null ? 'Add Pet' : 'Edit Pet',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.pets,
                            size: 100,
                            color: Colors.grey,
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
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
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Pet Name',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
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
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                    decoration: InputDecoration(
                                          hintText: 'Breed',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            color: Colors.grey[600],
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
                          const Icon(Icons.pets, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'About',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
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
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
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
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
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
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'N/A',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.grey,
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
                          const Icon(Icons.note, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Personal Note',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Personal Note
              TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a personal note about your pet...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
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
                          contentPadding: const EdgeInsets.all(16),
                        ),
                onSaved: (v) => notes = v,
              ),
                      
                      const SizedBox(height: 32),
                      
                      // Species Section
                      Row(
                        children: [
                          const Icon(Icons.category, color: Colors.black, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Species',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            color: Colors.grey[600],
                          ),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      
                      if (species == 'Other')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextFormField(
                            controller: _speciesOtherController,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Bird, Rabbit, Hamster',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
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
                  
                  if (widget.pet != null && widget.pet!.photoPath != null && widget.pet!.photoPath != photoPath) {
                    await _img.deleteImage(widget.pet!.photoPath);
                  }
                  
                  final pet = PetModel(
                    id: widget.pet?.id,
                    name: name,
                    species: species,
                    gender: gender,
                    age: age,
                    breed: breed,
                    photoPath: photoPath,
                    notes: notes,
                              weight: weight.isEmpty ? null : weight,
                              height: height.isEmpty ? null : height,
                              color: color.isEmpty ? null : color,
                  );
                  final provider = context.read<PetProvider>();
                  if (widget.pet == null) {
                    await provider.addPet(pet);
                  } else {
                    await provider.updatePet(widget.pet!.id!, pet);
                  }
                  if (!mounted) return;
                  Navigator.pop(context, pet);
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5D4).withOpacity(0.3), // Light peach background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in white circular background
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
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
