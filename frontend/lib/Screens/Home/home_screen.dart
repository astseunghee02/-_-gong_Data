import 'dart:math';

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../data/user_progress_controller.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatKoreanDate(DateTime.now());
    final motivationMessage = _getRandomMotivationMessage();

    return ValueListenableBuilder<UserProgressState>(
      valueListenable: UserProgressController.instance.notifier,
      builder: (context, progressState, _) {
        final characterData = _applyMissionExperience(
          _applyInactivityPenalty(
            _characterStatus,
            progressState.completionHistory,
          ),
          progressState.missionPoints,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
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
                  _WeatherBanner(
                    dateString: dateLabel,
                    weather: _homeWeather,
                    message: motivationMessage,
                  ),
                  const SizedBox(height: 16),
                  _CharacterCard(data: characterData),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeatherBanner extends StatelessWidget {
  final String dateString;
  final _WeatherInfo weather;
  final String message;

  const _WeatherBanner({
    required this.dateString,
    required this.weather,
    required this.message,
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
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
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
                '${weather.temperature}${String.fromCharCode(0x00B0)}C',
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

const double _characterHighlightSize = 233;
const Color _levelGaugeColor = Color(0xFFFFB74D);
const int _maxLevel = 50;
const Duration _inactivityThreshold = Duration(days: 7);

class _CharacterCard extends StatelessWidget {
  final _CharacterStatusData data;

  const _CharacterCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  'Lv.${data.level}',
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/pori-user.png',
                    height: _characterHighlightSize,
                    width: _characterHighlightSize,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _LevelGauge(data: data),
        ],
      ),
    );
  }
}

class _LevelGauge extends StatelessWidget {
  final _CharacterStatusData data;

  const _LevelGauge({required this.data});

  @override
  Widget build(BuildContext context) {
    final progress = _calculateLevelProgress(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '레벨 게이지',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Lv.${data.level} / $_maxLevel',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 14,
              backgroundColor: const Color(0xFFE7EBF3),
              valueColor: const AlwaysStoppedAnimation<Color>(_levelGaugeColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress.isMaxLevel
                ? '최대 레벨에 도달했어요'
                : '다음 레벨까지 ${progress.pointsToNext} 포인트 필요',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
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
  final int experience;

  const _CharacterStatusData({
    required this.name,
    required this.level,
    required this.experience,
  });

  _CharacterStatusData copyWith({
    String? name,
    int? level,
    int? experience,
  }) {
    return _CharacterStatusData(
      name: name ?? this.name,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }
}

class _LevelProgressData {
  final double ratio;
  final bool isMaxLevel;
  final int pointsToNext;

  const _LevelProgressData({
    required this.ratio,
    required this.isMaxLevel,
    required this.pointsToNext,
  });
}

_LevelProgressData _calculateLevelProgress(_CharacterStatusData data) {
  final currentLevel = data.level.clamp(1, _maxLevel);
  final isMaxLevel = currentLevel >= _maxLevel;
  final currentFloor = _requiredPointsForLevel(currentLevel);
  final nextFloor =
      isMaxLevel ? currentFloor : _requiredPointsForLevel(currentLevel + 1);

  final safeExperience = isMaxLevel
      ? currentFloor.toDouble()
      : data.experience.clamp(currentFloor, nextFloor).toDouble();
  final totalSpan = nextFloor - currentFloor;
  final ratio = isMaxLevel
      ? 1.0
      : totalSpan <= 0
          ? 0.0
          : (safeExperience - currentFloor) / totalSpan;
  final remainingPoints =
      isMaxLevel ? 0 : max(0, nextFloor - data.experience).toInt();

  final normalizedRatio = ratio.clamp(0.0, 1.0).toDouble();

  return _LevelProgressData(
    ratio: normalizedRatio,
    isMaxLevel: isMaxLevel,
    pointsToNext: remainingPoints,
  );
}

int _requiredPointsForLevel(int level) {
  if (level <= 1) {
    return 0;
  }
  final n = level - 1;
  return (n * (n + 1) ~/ 2) * 250;
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
  experience: 27780,
);

_CharacterStatusData _applyInactivityPenalty(
  _CharacterStatusData data,
  List<DateTime> completionHistory,
) {
  final penaltyLevels = _calculatePenaltyLevels(completionHistory);
  if (penaltyLevels <= 0) {
    return data;
  }

  final downgradedLevel = (data.level - penaltyLevels).clamp(1, _maxLevel);
  final adjustedExperience = min(
    data.experience,
    _requiredPointsForLevel(downgradedLevel),
  );

  return data.copyWith(
    level: downgradedLevel,
    experience: adjustedExperience,
  );
}

int _calculatePenaltyLevels(List<DateTime> completionHistory) {
  if (completionHistory.isEmpty) {
    return 1;
  }

  final latestCompletion = completionHistory.reduce(
    (a, b) => a.isAfter(b) ? a : b,
  );
  final now = DateTime.now();
  final difference = now.difference(latestCompletion);
  if (difference.isNegative || difference <= _inactivityThreshold) {
    return 0;
  }

  final weeks = difference.inDays ~/ _inactivityThreshold.inDays;
  return max(1, weeks);
}

_CharacterStatusData _applyMissionExperience(
  _CharacterStatusData data,
  int missionPoints,
) {
  if (missionPoints <= 0) {
    return data;
  }

  final totalExperience = data.experience + missionPoints;
  final cappedExperience = min(
    totalExperience,
    _requiredPointsForLevel(_maxLevel),
  );
  final derivedLevel = _levelForExperience(cappedExperience);

  return data.copyWith(
    level: derivedLevel,
    experience: cappedExperience,
  );
}

int _levelForExperience(int experience) {
  for (var level = 1; level < _maxLevel; level++) {
    final nextFloor = _requiredPointsForLevel(level + 1);
    if (experience < nextFloor) {
      return level;
    }
  }
  return _maxLevel;
}

String _getRandomMotivationMessage() {
  final random = Random();
  return _motivationMessages[random.nextInt(_motivationMessages.length)];
}

const List<String> _motivationMessages = [
  '오늘도 공공체육과 함께 활기차게',
  '오늘도 핏메이트와 함께 건강한 하루를 시작해볼까요',
  '오늘도 핏메이트와 함께 활기차게!',
  '가까운 공공체육시설에서 오늘도 한 걸음 더!',
  '오늘도 한 번 더! 공공체육시설에서 몸과 마음을 깨워요',
  '운동하기 좋은 날! 핏메이트와 함께 움직여봐요',
  '가까운 체육시설에서 가볍게 몸을 풀어볼까요?',
];









