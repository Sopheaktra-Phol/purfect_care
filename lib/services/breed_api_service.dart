import 'dart:convert';
import 'package:http/http.dart' as http;

class BreedApiService {
  static final BreedApiService _instance = BreedApiService._internal();
  factory BreedApiService() => _instance;
  BreedApiService._internal();

  // Cache for breeds to avoid repeated API calls
  List<String>? _dogBreeds;
  List<String>? _catBreeds;
  bool _isLoadingDogs = false;
  bool _isLoadingCats = false;

  /// Fetch all dog breeds from Dog CEO API
  Future<List<String>> getDogBreeds() async {
    if (_dogBreeds != null) return _dogBreeds!;
    if (_isLoadingDogs) {
      // Wait a bit if already loading
      await Future.delayed(const Duration(milliseconds: 500));
      if (_dogBreeds != null) return _dogBreeds!;
    }

    _isLoadingDogs = true;
    try {
      final response = await http.get(
        Uri.parse('https://dog.ceo/api/breeds/list/all'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final breedsMap = data['message'] as Map<String, dynamic>;
        final breeds = <String>[];

        // Extract all breeds (including sub-breeds)
        breedsMap.forEach((breed, subBreeds) {
          breeds.add(breed);
          if (subBreeds is List && subBreeds.isNotEmpty) {
            for (var subBreed in subBreeds) {
              breeds.add('$subBreed $breed');
            }
          }
        });

        // Sort and capitalize first letter
        breeds.sort();
        _dogBreeds = breeds.map((b) => _capitalizeBreed(b)).toList();
        return _dogBreeds!;
      } else {
        throw Exception('Failed to load dog breeds');
      }
    } catch (e) {
      // Return empty list on error, user can still type manually
      return [];
    } finally {
      _isLoadingDogs = false;
    }
  }

  /// Fetch all cat breeds from The Cat API
  Future<List<String>> getCatBreeds() async {
    if (_catBreeds != null) return _catBreeds!;
    if (_isLoadingCats) {
      // Wait a bit if already loading
      await Future.delayed(const Duration(milliseconds: 500));
      if (_catBreeds != null) return _catBreeds!;
    }

    _isLoadingCats = true;
    try {
      final response = await http.get(
        Uri.parse('https://api.thecatapi.com/v1/breeds'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final breeds = data
            .map((breed) => breed['name'] as String)
            .where((name) => name != null)
            .toList();
        breeds.sort();
        _catBreeds = breeds;
        return _catBreeds!;
      } else {
        // Fallback to common cat breeds if API fails
        return _getCommonCatBreeds();
      }
    } catch (e) {
      // Fallback to common cat breeds on error
      return _getCommonCatBreeds();
    } finally {
      _isLoadingCats = false;
    }
  }

  /// Get common cat breeds as fallback
  List<String> _getCommonCatBreeds() {
    return [
      'Abyssinian',
      'American Bobtail',
      'American Curl',
      'American Shorthair',
      'Bengal',
      'Birman',
      'British Shorthair',
      'Burmese',
      'Chartreux',
      'Cornish Rex',
      'Devon Rex',
      'Egyptian Mau',
      'Exotic Shorthair',
      'Himalayan',
      'Maine Coon',
      'Manx',
      'Norwegian Forest',
      'Persian',
      'Ragdoll',
      'Russian Blue',
      'Scottish Fold',
      'Siamese',
      'Siberian',
      'Sphynx',
      'Tonkinese',
      'Turkish Angora',
    ];
  }

  /// Capitalize breed name properly
  String _capitalizeBreed(String breed) {
    if (breed.isEmpty) return breed;
    final words = breed.split(' ');
    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Filter breeds based on search query
  List<String> filterBreeds(List<String> breeds, String query) {
    if (query.isEmpty) return breeds;
    final lowerQuery = query.toLowerCase();
    return breeds
        .where((breed) => breed.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Clear cache (useful for testing or refreshing)
  void clearCache() {
    _dogBreeds = null;
    _catBreeds = null;
  }
}

