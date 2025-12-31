import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:purfect_care/models/pet_model.dart';
import 'package:purfect_care/models/pet_photo_model.dart';
import 'package:purfect_care/providers/photo_provider.dart';
import 'package:purfect_care/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PhotoViewScreen extends StatefulWidget {
  final PetModel pet;
  final PetPhotoModel photo;
  final List<PetPhotoModel> photos;

  const PhotoViewScreen({
    super.key,
    required this.pet,
    required this.photo,
    required this.photos,
  });

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.photos.indexWhere((p) => p.id == widget.photo.id);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPhotoOptions(PetPhotoModel photo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: theme.colorScheme.onSurface),
              title: const Text('Edit Caption'),
              onTap: () {
                Navigator.pop(context);
                _showEditCaptionDialog(photo);
              },
            ),
            ListTile(
              leading: Icon(
                photo.isPrimary ? Icons.star : Icons.star_border,
                color: photo.isPrimary ? Colors.blue : theme.colorScheme.onSurface,
              ),
              title: Text(photo.isPrimary ? 'Remove as Primary' : 'Set as Primary Photo'),
              onTap: () {
                Navigator.pop(context);
                final photoProvider = context.read<PhotoProvider>();
                if (photo.isPrimary) {
                  // Can't remove if it's the only photo
                  if (widget.photos.length > 1) {
                    // Find another photo to set as primary
                    final otherPhoto = widget.photos.firstWhere(
                      (p) => p.id != photo.id,
                      orElse: () => widget.photos.first,
                    );
                    if (otherPhoto.id != null) {
                      photoProvider.setPrimaryPhoto(widget.pet.id!, otherPhoto.id!);
                    }
                  }
                } else {
                  if (photo.id != null) {
                    photoProvider.setPrimaryPhoto(widget.pet.id!, photo.id!);
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(photo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCaptionDialog(PetPhotoModel photo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController(text: photo.caption);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text('Edit Caption'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a caption...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (photo.id != null) {
                final updatedPhoto = PetPhotoModel(
                  id: photo.id,
                  petId: photo.petId,
                  photoUrl: photo.photoUrl,
                  thumbnailUrl: photo.thumbnailUrl,
                  dateTaken: photo.dateTaken,
                  caption: controller.text.trim().isEmpty ? null : controller.text.trim(),
                  isPrimary: photo.isPrimary,
                );
                context.read<PhotoProvider>().updatePhoto(
                      widget.pet.id!,
                      photo.id!,
                      updatedPhoto,
                    );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? theme.colorScheme.primary : AppTheme.accentOrange,
              foregroundColor: isDark ? theme.colorScheme.onPrimary : Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PetPhotoModel photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (photo.id != null) {
                context.read<PhotoProvider>().deletePhoto(widget.pet.id!, photo.id!);
              }
              Navigator.pop(context);
              if (widget.photos.length <= 1) {
                Navigator.pop(context); // Go back to gallery if last photo
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPhoto = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showPhotoOptions(currentPhoto),
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final photo = widget.photos[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(photo.photoUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            itemCount: widget.photos.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          // Caption overlay
          if (currentPhoto.caption != null && currentPhoto.caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentPhoto.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(currentPhoto.dateTaken),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

