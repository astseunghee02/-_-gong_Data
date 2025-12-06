import 'package:flutter/material.dart';
import '../recommend_backend/recommendation_models.dart';

class RecommendationSectionFromApi extends StatelessWidget {
  final double bmi;
  final String difficulty;
  final List<RecommendationLevel> levels;
  final String userName; // "현아" 이런 이름

  const RecommendationSectionFromApi({
    super.key,
    required this.bmi,
    required this.difficulty,
    required this.levels,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$userName님을 위한 운동 추천',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '현재 BMI: $bmi, 난이도: $difficulty',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // level = 상 / 중 / 하 순서대로 카드 만들기
        Column(
          children: levels.map((level) {
            return _buildLevelCard(context, level);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelCard(BuildContext context, RecommendationLevel level) {
    final title = switch (level.level) {
      "상" => "고강도 유산소 + 근력",
      "중" => "중강도 유산소 + 코어",
      _ => "저강도 유산소 + 스트레칭",
    };

    final tag = switch (level.level) {
      "상" => "고강도 · 주 3회 이상",
      "중" => "중강도 · 주 3~4회",
      _ => "저강도 · 주 5회",
    };

    final color = switch (level.level) {
      "상" => Colors.redAccent,
      "중" => Colors.orangeAccent,
      _ => Colors.blueAccent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 태그 줄 (예: 20~30대 / 중강도 · 주 3회)
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  level.level, // "상" / "중" / "하"
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tag,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // 처방 문장 여러 개 중 첫 줄만 요약으로 보여주기
          Text(
            level.prescriptions.isNotEmpty
                ? level.prescriptions.first
                : '맞춤 운동 처방을 불러오는 중입니다.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
