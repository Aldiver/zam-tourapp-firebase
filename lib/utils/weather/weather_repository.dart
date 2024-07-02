import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherRepository {
  final String apiKey = 'c1333888bec84b6cb0091233240107'; // Replace with your actual API key

  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$latitude,$longitude'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
