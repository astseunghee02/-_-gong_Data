class RecommendationLevel {
  final String level; // "상" / "중" / "하"
  final List<String> prescriptions;

  RecommendationLevel({
    required this.level,
    required this.prescriptions,
  });

  factory RecommendationLevel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['prescriptions'] ?? [];
    return RecommendationLevel(
      level: json['level'] ?? '',
      prescriptions: list.map((e) => e.toString()).toList(),
    );
  }
}

class RecommendationResponse {
  final double bmi;
  final String difficulty; // "상" / "중" / "하"
  final List<RecommendationLevel> levels;

  RecommendationResponse({
    required this.bmi,
    required this.difficulty,
    required this.levels,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['recommendations'] ?? [];
    return RecommendationResponse(
      bmi: (json['bmi'] ?? 0).toDouble(),
      difficulty: json['difficulty'] ?? '',
      levels:
      list.map((e) => RecommendationLevel.fromJson(e)).toList(),
    );
  }
}
