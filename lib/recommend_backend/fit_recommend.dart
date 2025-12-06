import 'dart:convert';
import 'package:http/http.dart' as http;
import '../recommend_backend/recommendation_models.dart';

class RecommendService {
  // TODO: 환경에 맞게 수정 == == 나중에 수정 필요 지금은 웹 버전
  // final String baseUrl = "http://10.0.2.2:8000";
  final String baseUrl = "http://127.0.0.1:8000";

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
        "ageGroup": ageGroup,   // 예: "20대"
        "sex": sex,             // "M" 또는 "F"
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
