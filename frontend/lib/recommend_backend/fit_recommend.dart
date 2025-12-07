import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'recommendation_models.dart';

class RecommendService {
  // TODO: 환경에 맞게 수정 (필요 시 .env 사용)
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  Future<RecommendationResponse> getRecommendations({
    required String ageGroup,
    required String sex,
    required double heightCm,
    required double weightKg,
  }) async {
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
