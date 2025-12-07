import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final String conditionMain;
  final String description;

  WeatherData({
    required this.temperature,
    required this.conditionMain,
    required this.description,
  });
}

class WeatherService {
  WeatherService._internal();
  static final WeatherService instance = WeatherService._internal();

  Future<WeatherData?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$baseUrl/api/weather/?lat=$latitude&lon=$longitude',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final main = data['main'] as Map<String, dynamic>? ?? {};
      final weatherList = data['weather'] as List<dynamic>? ?? [];
      final firstWeather = weatherList.isNotEmpty
          ? weatherList.first as Map<String, dynamic>
          : {};

      return WeatherData(
        temperature: (main['temp'] as num?)?.toDouble() ?? 0,
        conditionMain: (firstWeather['main'] as String?) ?? 'Clouds',
        description: (firstWeather['description'] as String?) ?? '',
      );
    } catch (e) {
      print('❌ fetchWeather error: $e');
      return null;
    }
  }
}
