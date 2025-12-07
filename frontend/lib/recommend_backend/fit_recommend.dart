import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'recommendation_models.dart';

class RecommendService {
  Future<RecommendationResponse> getRecommendations({
    required String ageGroup,
    required String sex,
    required double heightCm,
    required double weightKg,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception("API_BASE_URL not configured. Please check your .env file.");
    }

    final url = Uri.parse("$baseUrl/recommendations");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ageGroup": ageGroup,
        "sex": sex,
        "heightCm": heightCm,
        "weightKg": weightKg,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return RecommendationResponse.fromJson(json);
    } else {
      throw Exception("추천 API 요청 실패: ${response.statusCode}");
    }
  }
}
