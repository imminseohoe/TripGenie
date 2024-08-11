// pixabay_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayApi {
  static const String _apiKey = 'API-KEY';
  static const String _baseUrl = 'https://pixabay.com/api/';

  static Future<String> fetchImageUrl(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?key=$_apiKey&q=$query&image_type=photo&per_page=3'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final imageUrl = data['hits'][0]['webformatURL'];
      return imageUrl;
    } else {
      throw Exception('Failed to load image');
    }
  }
}
