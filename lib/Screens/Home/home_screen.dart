import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Map/map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatKoreanDate(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          items: buildAppBottomNavItems(
            context,
            AppNavDestination.home,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WeatherBanner(dateString: dateLabel, weather: _homeWeather),
              const SizedBox(height: 16),
              const _CharacterCard(data: _characterStatus),
              const SizedBox(height: 16),
              const _MissionSection(data: _missionProgress),
              const SizedBox(height: 16),
              const _FacilitySection(facilities: _facilities),
              const SizedBox(height: 16),
              const _ProgramSection(programs: _programs),
              const SizedBox(height: 16),
              const _RecommendationSection(
                recommendations: _ageRecommendations,
                comparison: _fitnessComparison,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherBanner extends StatelessWidget {
  final String dateString;
  final _WeatherInfo weather;

  const _WeatherBanner({
    required this.dateString,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForWeather(weather.condition);
    final iconColor = _colorForWeather(weather.condition);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF4FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '오늘도 공공체육과 함께 활기차게!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 40,
              ),
              const SizedBox(width: 8),
              Text(
                '${weather.temperature}°C',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final _CharacterStatusData data;

  const _CharacterCard({required this.data});

  @override
  Widget build(BuildContext context) {
    const stats = [
      _StatMeterData(
        label: '상체',
        value: _MetricValue.health,
      ),
      _StatMeterData(
        label: '하체',
        value: _MetricValue.energy,
      ),
      _StatMeterData(
        label: '코어',
        value: _MetricValue.defense,
      ),
    ];

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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘의 캐릭터',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lv.${data.level}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F6F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.self_improvement,
                  size: 34,
                  color: Color(0xFF3C86C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: stats
                .map(
                  (stat) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: stat == stats.last ? 0 : 10,
                      ),
                      child: _StatMeter(
                        label: stat.label,
                        value: stat.value.extractValue(data),
                        color: stat.value.color,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  final _MissionProgressData data;

  const _MissionSection({required this.data});

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
          const Text(
            '오늘/주간 미션 진행도',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _MissionProgressTile(
            title: '오늘의 미션',
            completed: data.daily.completed,
            total: data.daily.total,
            color: const Color(0xFF3C86C0),
          ),
          const SizedBox(height: 12),
          _MissionProgressTile(
            title: '주간 미션',
            completed: data.weekly.completed,
            total: data.weekly.total,
            color: const Color(0xFF8E7CFF),
          ),
        ],
      ),
    );
  }
}

class _FacilitySection extends StatelessWidget {
  final List<_FacilityInfo> facilities;

  const _FacilitySection({required this.facilities});

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3C86C0),
                ),
                child: const Text('지도에서 보기'),
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

class _ProgramSection extends StatelessWidget {
  final List<_ProgramInfo> programs;

  const _ProgramSection({required this.programs});

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
                '참여 가능한 프로그램',
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

class _RecommendationSection extends StatelessWidget {
  final List<_AgeRecommendation> recommendations;
  final _FitnessComparisonData comparison;

  const _RecommendationSection({
    required this.recommendations,
    required this.comparison,
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
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0xFFECEFF5),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(
                Icons.insights_outlined,
                color: Color(0xFF3C86C0),
              ),
              SizedBox(width: 6),
              Text(
                '내 체력 비교',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FitnessComparisonCard(data: comparison),
        ],
      ),
    );
  }
}

class _AgeRecommendationCard extends StatelessWidget {
  final _AgeRecommendation info;

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
  final _FitnessComparisonData data;

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
            label: '내 체력 지수',
            score: data.userScore,
            color: const Color(0xFF3C86C0),
            description: '이 연령대 상위 ${data.userPercentile}% 수준',
          ),
          const SizedBox(height: 14),
          _ComparisonBar(
            label: '지역 평균',
            score: data.regionalAverageScore,
            color: const Color(0xFFA0AEC0),
            description: '비슷한 연령대 평균 체력',
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
            value: score / 100,
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

class _StatMeter extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatMeter({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 8,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFE7EBF3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value%',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

class _MissionProgressTile extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final Color color;

  const _MissionProgressTile({
    required this.title,
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$completed / $total',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE7EBF3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _FacilityTile extends StatelessWidget {
  final _FacilityInfo info;

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
  final _ProgramInfo info;

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

class _WeatherInfo {
  final _WeatherCondition condition;
  final int temperature;

  const _WeatherInfo({
    required this.condition,
    required this.temperature,
  });
}

enum _WeatherCondition { sunny, cloudy, rainy }

class _CharacterStatusData {
  final String name;
  final int level;
  final int health;
  final int energy;
  final int defense;

  const _CharacterStatusData({
    required this.name,
    required this.level,
    required this.health,
    required this.energy,
    required this.defense,
  });
}

class _MissionProgressData {
  final _MissionCounter daily;
  final _MissionCounter weekly;

  const _MissionProgressData({
    required this.daily,
    required this.weekly,
  });
}

class _MissionCounter {
  final int completed;
  final int total;

  const _MissionCounter({
    required this.completed,
    required this.total,
  });
}

class _FacilityInfo {
  final String name;
  final String distance;
  final double rating;
  final int programs;

  const _FacilityInfo({
    required this.name,
    required this.distance,
    required this.rating,
    required this.programs,
  });
}

class _ProgramInfo {
  final String name;
  final String facility;
  final String time;
  final int participants;
  final int maxParticipants;

  const _ProgramInfo({
    required this.name,
    required this.facility,
    required this.time,
    required this.participants,
    required this.maxParticipants,
  });
}

class _AgeRecommendation {
  final String ageRange;
  final String recommendation;
  final String intensityLabel;
  final String description;

  const _AgeRecommendation({
    required this.ageRange,
    required this.recommendation,
    required this.intensityLabel,
    required this.description,
  });
}

class _FitnessComparisonData {
  final int userScore;
  final int userPercentile;
  final int regionalAverageScore;

  const _FitnessComparisonData({
    required this.userScore,
    required this.userPercentile,
    required this.regionalAverageScore,
  });
}

enum _MetricValue {
  health(Color(0xFFE57373)),
  energy(Color(0xFFFFB74D)),
  defense(Color(0xFF64B5F6));

  final Color color;

  const _MetricValue(this.color);

  int extractValue(_CharacterStatusData data) {
    switch (this) {
      case _MetricValue.health:
        return data.health;
      case _MetricValue.energy:
        return data.energy;
      case _MetricValue.defense:
        return data.defense;
    }
  }
}

class _StatMeterData {
  final String label;
  final _MetricValue value;

  const _StatMeterData({
    required this.label,
    required this.value,
  });
}

String _formatKoreanDate(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekdayLabel = weekdays[date.weekday - 1];
  return '${date.year}년 ${date.month}월 ${date.day}일 ($weekdayLabel)';
}

IconData _iconForWeather(_WeatherCondition condition) {
  switch (condition) {
    case _WeatherCondition.sunny:
      return Icons.wb_sunny_rounded;
    case _WeatherCondition.cloudy:
      return Icons.wb_cloudy_rounded;
    case _WeatherCondition.rainy:
      return Icons.umbrella;
  }
}

Color _colorForWeather(_WeatherCondition condition) {
  switch (condition) {
    case _WeatherCondition.sunny:
      return const Color(0xFFFFB74D);
    case _WeatherCondition.cloudy:
      return const Color(0xFF90A4AE);
    case _WeatherCondition.rainy:
      return const Color(0xFF4FC3F7);
  }
}

const _WeatherInfo _homeWeather = _WeatherInfo(
  condition: _WeatherCondition.sunny,
  temperature: 22,
);

const _CharacterStatusData _characterStatus = _CharacterStatusData(
  name: '텅구리',
  level: 15,
  health: 85,
  energy: 70,
  defense: 60,
);

const _MissionProgressData _missionProgress = _MissionProgressData(
  daily: _MissionCounter(completed: 3, total: 5),
  weekly: _MissionCounter(completed: 7, total: 12),
);

const List<_FacilityInfo> _facilities = [
  _FacilityInfo(
    name: '중구 체육센터',
    distance: '0.5km',
    rating: 4.5,
    programs: 3,
  ),
  _FacilityInfo(
    name: '한강 수영장',
    distance: '0.8km',
    rating: 4.7,
    programs: 2,
  ),
  _FacilityInfo(
    name: '용산 생활체육관',
    distance: '1.2km',
    rating: 4.3,
    programs: 5,
  ),
];

const List<_ProgramInfo> _programs = [
  _ProgramInfo(
    name: '오전 요가 클래스',
    facility: '중구 체육센터',
    time: '09:00 - 10:00',
    participants: 12,
    maxParticipants: 20,
  ),
  _ProgramInfo(
    name: '저녁 피트니스',
    facility: '중구 체육센터',
    time: '19:00 - 20:00',
    participants: 18,
    maxParticipants: 20,
  ),
  _ProgramInfo(
    name: '주말 배드민턴',
    facility: '용산 생활체육관',
    time: '토 14:00 - 16:00',
    participants: 8,
    maxParticipants: 16,
  ),
];

const List<_AgeRecommendation> _ageRecommendations = [
  _AgeRecommendation(
    ageRange: '20-30대',
    recommendation: 'HIIT + 코어 강화',
    intensityLabel: '중강도 · 주 3회',
    description: '짧고 강한 인터벌 운동으로 체지방을 줄이고 코어 근력을 키워 보세요.',
  ),
  _AgeRecommendation(
    ageRange: '40대',
    recommendation: '전신 근력 + 유산소 30분',
    intensityLabel: '중강도 · 주 4회',
    description: '근력과 유산소를 번갈아 진행하면 균형 잡힌 체력 향상에 도움이 됩니다.',
  ),
  _AgeRecommendation(
    ageRange: '50대 이상',
    recommendation: '저충격 유산소 + 유연성',
    intensityLabel: '저강도 · 주 5회',
    description: '걷기, 수영과 스트레칭을 병행해 관절 부담을 줄이면서 꾸준히 움직이세요.',
  ),
];

const _FitnessComparisonData _fitnessComparison = _FitnessComparisonData(
  userScore: 82,
  userPercentile: 20,
  regionalAverageScore: 68,
);
