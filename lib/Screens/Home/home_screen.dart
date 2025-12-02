import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

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









