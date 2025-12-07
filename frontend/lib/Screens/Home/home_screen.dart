 import 'dart:math';

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../data/user_progress_controller.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final int? userLevel;
  final String? userName;

  const HomeScreen({
    super.key,
    this.userLevel,
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _displayName = 'User';
  int _level = 1;
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService.instance;
  _WeatherInfo? _weatherInfo;
  bool _isLoadingWeather = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName ?? _displayName;
    _level = widget.userLevel ?? _level;
    _loadProfile();
    _loadWeather();
  }

  Future<void> _loadProfile() async {
    final cachedName = await AuthService.getCachedProfileName();
    final cachedLevel = await AuthService.getCachedProfileLevel();

    if (!mounted) return;
    setState(() {
      if (cachedName != null && cachedName.isNotEmpty) {
        _displayName = cachedName;
      }
      if (cachedLevel != null) {
        _level = cachedLevel;
      }
    });

    final profile = await AuthService.getUserProfile();
    if (!mounted || profile == null) return;

    final profileData = profile['profile'] as Map<String, dynamic>? ?? {};
    final fetchedName = (profileData['name'] as String?)?.trim();
    final fetchedLevel = profileData['level'] as int?;

    setState(() {
      if (fetchedName != null && fetchedName.isNotEmpty) {
        _displayName = fetchedName;
      } else if (profile['username'] is String) {
        _displayName = profile['username'] as String;
      }
      if (fetchedLevel != null) {
        _level = fetchedLevel;
      }
    });
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _isLoadingWeather = false;
        _weatherError = '현재 위치를 가져올 수 없습니다.';
      });
      return;
    }

    final weather = await _weatherService.fetchWeather(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (!mounted) return;
    setState(() {
      _isLoadingWeather = false;
      if (weather == null) {
        _weatherError = '날씨 정보를 불러오지 못했습니다.';
        return;
      }

      _weatherInfo = _WeatherInfo(
        condition: _mapCondition(weather.conditionMain),
        temperature: weather.temperature.round(),
        description: weather.description,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatKoreanDate(DateTime.now());
    final motivationMessage = _getRandomMotivationMessage();

    return ValueListenableBuilder<UserProgressState>(
      valueListenable: UserProgressController.instance.notifier,
      builder: (context, progressState, _) {
        // DB에서 가져온 레벨을 사용
        final characterData = _CharacterStatusData(
          name: _displayName,
          level: _level,
          experience: progressState.missionPoints % 100,
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
                    weather: _weatherInfo ?? _homeWeather,
                    message: motivationMessage,
                    isLoading: _isLoadingWeather,
                    errorText: _weatherError,
                    onRefresh: _loadWeather,
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
  final bool isLoading;
  final String? errorText;
  final VoidCallback onRefresh;

  const _WeatherBanner({
    required this.dateString,
    required this.weather,
    required this.message,
    required this.isLoading,
    required this.errorText,
    required this.onRefresh,
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
                if (isLoading)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '날씨를 불러오는 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  )
                else if (errorText != null)
                  Text(
                    errorText!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (weather.description != null && weather.description!.isNotEmpty)
                    Text(
                      weather.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
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
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                color: Colors.black54,
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
                    _getCharacterImage(data.level),
                    height: _characterHighlightSize,
                    width: _characterHighlightSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/pori-user.png',
                        height: _characterHighlightSize,
                        width: _characterHighlightSize,
                        fit: BoxFit.cover,
                      );
                    },
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
  final String? description;

  const _WeatherInfo({
    required this.condition,
    required this.temperature,
    this.description,
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

_WeatherCondition _mapCondition(String conditionMain) {
  final lower = conditionMain.toLowerCase();
  if (lower.contains('rain') ||
      lower.contains('drizzle') ||
      lower.contains('thunder') ||
      lower.contains('snow')) {
    return _WeatherCondition.rainy;
  }
  if (lower.contains('cloud') || lower.contains('mist') || lower.contains('fog')) {
    return _WeatherCondition.cloudy;
  }
  return _WeatherCondition.sunny;
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
  description: '맑음',
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
  '오늘도 Work-Flow와 함께 \n건강한 하루를 시작해볼까요',
  '오늘도 Work-Flow와 함께 활기차게!',
  '가까운 공공체육시설에서 오늘도 한 걸음 더!',
  '오늘도 한 번 더! \n공공체육시설에서 몸과 마음을 깨워요',
  '운동하기 좋은 날! \nWork-Flow와 함께 움직여봐요',
  '가까운 체육시설에서 가볍게 \n몸을 풀어볼까요?',
];

String _getCharacterImage(int level) {
  if (level < 10) return 'assets/pori/pori_01.png';
  if (level < 20) return 'assets/pori/pori_10.png';
  if (level < 30) return 'assets/pori/pori_20.png';
  if (level < 40) return 'assets/pori/pori_30.png';
  if (level < 50) return 'assets/pori/pori_40.png';
  return 'assets/pori/pori_50.png';
}




