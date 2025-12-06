import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/pedometer_service.dart';
import '../../services/location_service.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// 만보기와 GPS 기능이 통합된 홈 화면
///
/// 사용 방법:
/// 1. main.dart에서 '/home' 라우트를 HomeScreenWithSensors로 변경
/// 2. 또는 아래처럼 직접 사용:
///    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreenWithSensors()));
class HomeScreenWithSensors extends StatefulWidget {
  const HomeScreenWithSensors({super.key});

  @override
  State<HomeScreenWithSensors> createState() => _HomeScreenWithSensorsState();
}

class _HomeScreenWithSensorsState extends State<HomeScreenWithSensors> {
  final PedometerService _pedometerService = PedometerService();
  final LocationService _locationService = LocationService();

  int _steps = 0;
  double? _latitude;
  double? _longitude;
  String _locationStatus = '위치 정보 로딩 중...';

  StreamSubscription<int>? _stepsSubscription;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  /// 센서 초기화
  Future<void> _initSensors() async {
    // 만보기 시작
    final pedometerStarted = await _pedometerService.startTracking();
    if (pedometerStarted) {
      _stepsSubscription = _pedometerService.stepsStream.listen((steps) {
        setState(() {
          _steps = steps;
        });
      });
    }

    // GPS 위치 가져오기
    await _updateLocation();
  }

  /// 위치 업데이트
  Future<void> _updateLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationStatus = '위치 정보 수신 완료';
      });
    } else {
      setState(() {
        _locationStatus = '위치 정보를 가져올 수 없습니다';
      });
    }
  }

  @override
  void dispose() {
    _stepsSubscription?.cancel();
    _pedometerService.stopTracking();
    super.dispose();
  }

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

              // 걸음 수 카드
              _StepsCard(steps: _steps),
              const SizedBox(height: 16),

              // GPS 위치 카드
              _LocationCard(
                latitude: _latitude,
                longitude: _longitude,
                status: _locationStatus,
                onRefresh: _updateLocation,
              ),
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

/// 걸음 수 카드
class _StepsCard extends StatelessWidget {
  final int steps;

  const _StepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Colors.white],
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_walk,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 걸음 수',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$steps 걸음',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${(steps / 10000 * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),
              const Text(
                '만보 달성률',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// GPS 위치 카드
class _LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String status;
  final VoidCallback onRefresh;

  const _LocationCard({
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Colors.white],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 위치',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
          if (latitude != null && longitude != null) ...[
            const SizedBox(height: 16),
            _LocationDataRow(
              icon: Icons.north,
              label: '위도 (Latitude)',
              value: latitude!.toStringAsFixed(6),
            ),
            const SizedBox(height: 8),
            _LocationDataRow(
              icon: Icons.east,
              label: '경도 (Longitude)',
              value: longitude!.toStringAsFixed(6),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationDataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LocationDataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE65100),
          ),
        ),
      ],
    );
  }
}

// 기존 홈 화면 위젯들 (WeatherBanner, CharacterCard 등)
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
                    fontSize: 15,
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

const double _characterHighlightSize = 350;

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
