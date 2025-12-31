import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purfect_care/services/image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget that safely displays an image file or URL, showing a placeholder if the file doesn't exist
class SafeImage extends StatelessWidget {
  final String? imagePath;
  final BoxFit fit;
  final Widget? placeholder;
  final double? width;
  final double? height;

  const SafeImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.width,
    this.height,
  });

  /// Check if the imagePath is a URL (starts with http:// or https://)
  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder(context);
    }

    // If it's a URL (Firebase Storage), use CachedNetworkImage
    if (_isUrl(imagePath!)) {
      return CachedNetworkImage(
        imageUrl: imagePath!,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }

    // Otherwise, it's a local file path
    return FutureBuilder<bool>(
      future: ImageService().imageExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder(context);
        }

        if (snapshot.data == true) {
          return Image.file(
            File(imagePath!),
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          );
        }

        return _buildPlaceholder(context);
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      child: Icon(
        Icons.pets,
        size: width != null && height != null
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 48,
        color: Colors.white,
      ),
    );
  }
}

/// A CircleAvatar that safely displays an image file or URL
class SafeCircleAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final Widget? child;

  const SafeCircleAvatar({
    super.key,
    required this.imagePath,
    required this.radius,
    this.child,
  });

  /// Check if the imagePath is a URL (starts with http:// or https://)
  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: child ?? const Icon(Icons.pets),
      );
    }

    // If it's a URL (Firebase Storage), use CachedNetworkImage
    if (_isUrl(imagePath!)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(imagePath!),
        onBackgroundImageError: (exception, stackTrace) {
          // Image failed to load, will show child instead
        },
        child: child ?? const Icon(Icons.pets),
      );
    }

    // Otherwise, it's a local file path
    return FutureBuilder<bool>(
      future: ImageService().imageExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            child: child ?? const Icon(Icons.pets),
          );
        }

        if (snapshot.data == true) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(File(imagePath!)),
            onBackgroundImageError: (exception, stackTrace) {
              // Image failed to load, will show child instead
            },
            // Don't show child overlay when image exists
            child: null,
          );
        }

        return CircleAvatar(
          radius: radius,
          child: child ?? const Icon(Icons.pets),
        );
      },
    );
  }
}

