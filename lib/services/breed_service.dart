import 'dart:convert';
import 'package:http/http.dart' as http;

class BreedService {
  Future<List<String>> getDogBreeds() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['message'] as Map<String, dynamic>).keys.toList();
    } else {
      throw Exception('Failed to load dog breeds');
    }
  }

  Future<List<String>> getCatBreeds() async {
    final response = await http.get(Uri.parse('https://api.thecatapi.com/v1/breeds'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List).map((breed) => breed['name'] as String).toList();
    } else {
      throw Exception('Failed to load cat breeds');
    }
  }
}
