import 'package:flutter/material.dart';

class FacilityInfo {
  final String name;
  final String distance;
  final double rating;
  final int programs;

  const FacilityInfo({
    required this.name,
    required this.distance,
    required this.rating,
    required this.programs,
  });
}

class ProgramInfo {
  final String name;
  final String facility;
  final String time;
  final int participants;
  final int maxParticipants;

  const ProgramInfo({
    required this.name,
    required this.facility,
    required this.time,
    required this.participants,
    required this.maxParticipants,
  });
}

class AgeRecommendation {
  final String ageRange;
  final String recommendation;
  final String intensityLabel;
  final String description;

  const AgeRecommendation({
    required this.ageRange,
    required this.recommendation,
    required this.intensityLabel,
    required this.description,
  });
}

class FitnessComparisonData {
  final int userScore;
  final int userPercentile;
  final int regionalAverageScore;

  const FitnessComparisonData({
    required this.userScore,
    required this.userPercentile,
    required this.regionalAverageScore,
  });
}

class FacilitySection extends StatelessWidget {
  final List<FacilityInfo> facilities;
  final VoidCallback? onViewMore;

  const FacilitySection({
    super.key,
    required this.facilities,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF3C86C0),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '주변 공공체육시설',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewMore,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3C86C0),
                ),
                child: const Text('자세히보기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(
              facilities.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == facilities.length - 1 ? 0 : 10,
                ),
                child: _FacilityTile(info: facilities[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramSection extends StatelessWidget {
  final List<ProgramInfo> programs;

  const ProgramSection({super.key, required this.programs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '참여가능한 프로그램',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...programs.map(
            (program) => Padding(
              padding: EdgeInsets.only(
                bottom: program == programs.last ? 0 : 12,
              ),
              child: _ProgramCard(info: program),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationSection extends StatelessWidget {
  final List<AgeRecommendation> recommendations;
  final FitnessComparisonData? comparison;

  const RecommendationSection({
    super.key,
    required this.recommendations,
    this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.recommend_outlined,
                color: Color(0xFF7E57C2),
              ),
              SizedBox(width: 6),
              Text(
                '연령대별 운동 추천',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...recommendations.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == recommendations.last ? 0 : 12,
              ),
              child: _AgeRecommendationCard(info: item),
            ),
          ),
          if (comparison != null) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              width: double.infinity,
              color: const Color(0xFFECEFF5),
            ),
            const SizedBox(height: 20),
            FitnessComparisonBlock(data: comparison!),
          ],
        ],
      ),
    );
  }
}

class FitnessComparisonBlock extends StatelessWidget {
  final FitnessComparisonData data;

  const FitnessComparisonBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.insights_outlined,
              color: Color(0xFF3C86C0),
            ),
            SizedBox(width: 6),
            Text(
              '체력순위 비교',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FitnessComparisonCard(data: data),
      ],
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final FacilityInfo info;

  const _FacilityTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E8F3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      info.distance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      info.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${info.programs}개 프로그램',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ProgramInfo info;

  const _ProgramCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E8F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.facility,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C86C0),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: const Text(
                  '신청',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.black45,
              ),
              const SizedBox(width: 4),
              Text(
                info.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.people_alt_outlined,
                size: 16,
                color: Colors.black45,
              ),
              const SizedBox(width: 4),
              Text(
                '${info.participants}/${info.maxParticipants}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgeRecommendationCard extends StatelessWidget {
  final AgeRecommendation info;

  const _AgeRecommendationCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E8F3)),
        color: const Color(0xFFF9FAFF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  info.ageRange,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3C86C0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                info.intensityLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.recommendation,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _FitnessComparisonCard extends StatelessWidget {
  final FitnessComparisonData data;

  const _FitnessComparisonCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E8F3)),
      ),
      child: Column(
        children: [
          _ComparisonBar(
            label: '나의 체력',
            score: data.userScore,
            color: const Color(0xFF3C86C0),
            description: '연령대 상위 ${data.userPercentile}% 수준',
          ),
          const SizedBox(height: 14),
          _ComparisonBar(
            label: '지역 평균',
            score: data.regionalAverageScore,
            color: const Color(0xFFA0AEC0),
            description: '주변 지역 평균 체력',
          ),
        ],
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final String description;

  const _ComparisonBar({
    required this.label,
    required this.score,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$score점',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE7EBF3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

const List<FacilityInfo> defaultFacilities = [
  FacilityInfo(
    name: '중구 체육센터',
    distance: '0.5km',
    rating: 4.5,
    programs: 3,
  ),
  FacilityInfo(
    name: '한강 수영장',
    distance: '0.8km',
    rating: 4.7,
    programs: 2,
  ),
  FacilityInfo(
    name: '용산 생활체육관',
    distance: '1.2km',
    rating: 4.3,
    programs: 5,
  ),
];

const List<ProgramInfo> defaultPrograms = [
  ProgramInfo(
    name: '오전 요가 클래스',
    facility: '중구 체육센터',
    time: '09:00 - 10:00',
    participants: 12,
    maxParticipants: 20,
  ),
  ProgramInfo(
    name: '저녁 피트니스',
    facility: '중구 체육센터',
    time: '19:00 - 20:00',
    participants: 18,
    maxParticipants: 20,
  ),
  ProgramInfo(
    name: '주말 배드민턴',
    facility: '용산 생활체육관',
    time: '토 14:00 - 16:00',
    participants: 8,
    maxParticipants: 16,
  ),
];

const List<AgeRecommendation> defaultAgeRecommendations = [
  AgeRecommendation(
    ageRange: '20-30대',
    recommendation: 'HIIT + 코어 강화',
    intensityLabel: '중강도 · 주 3회',
    description: '짧고 강한 인터벌 운동으로 체지방을 줄이고 코어 근력을 키워 보세요.',
  ),
  AgeRecommendation(
    ageRange: '40대',
    recommendation: '전신 근력 + 유산소 30분',
    intensityLabel: '중강도 · 주 4회',
    description: '근력과 유산소를 번갈아 진행하면 균형 잡힌 체력 향상에 도움이 됩니다.',
  ),
  AgeRecommendation(
    ageRange: '50대 이상',
    recommendation: '저충격 유산소 + 유연성',
    intensityLabel: '저강도 · 주 5회',
    description: '걷기, 수영과 스트레칭을 병행해 관절 부담을 줄이면서 꾸준히 움직이세요.',
  ),
];

const FitnessComparisonData defaultFitnessComparison = FitnessComparisonData(
  userScore: 82,
  userPercentile: 20,
  regionalAverageScore: 68,
);
