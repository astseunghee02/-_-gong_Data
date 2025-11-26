import 'package:flutter/material.dart';
import '../Map/map_screen.dart';

class Mission {
  final String title;
  final String description;
  final String pointText;

  Mission({
    required this.title,
    required this.description,
    required this.pointText,
  });
}

class MissionScreen extends StatefulWidget {
  /// 지도 화면에서 "도전" 눌렀을 때 넘어오는 초기 미션 데이터
  final String? initialTitle;
  final String? initialDescription;
  final String? initialPoint;

  const MissionScreen({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialPoint,
  });

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final List<Mission> ongoingMissions = [];
  late List<Mission> availableMissions;

  @override
  void initState() {
    super.initState();

    // 기본 "도전 가능" 목록
    availableMissions = [
      Mission(
        title: '운동 인증샷 올리기',
        description: '운동 후 사진+위치 인증',
        pointText: '+500P',
      ),
      Mission(
        title: '오늘 인근 체육시설 방문',
        description: '인근 공원·체육시설 중 1곳 도착',
        pointText: '+750P',
      ),
      Mission(
        title: '천안천 산책',
        description: '천안천 산책로 따라 3km 걷기',
        pointText: '+700P',
      ),
    ];

    // 지도 화면에서 "도전" 눌러서 넘어온 미션이 있으면
    if (widget.initialTitle != null &&
        widget.initialDescription != null &&
        widget.initialPoint != null) {
      final fromMap = Mission(
        title: widget.initialTitle!,
        description: widget.initialDescription!,
        pointText: widget.initialPoint!,
      );
      ongoingMissions.add(fromMap);
    }
  }

  // 도전 가능 → 도전 중
  void _startMission(Mission mission) {
    setState(() {
      availableMissions.remove(mission);
      ongoingMissions.add(mission);
    });
  }

  // 도전 중 → 완료(리스트에서 제거)
  void _completeMission(Mission mission) {
    setState(() {
      ongoingMissions.remove(mission);
    });
  }

  // 지도 화면으로 이동
  void _goToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ✅ MapScreen 과 동일 스타일의 네비게이션 바
      bottomNavigationBar: SafeArea(
        top: false,
        child: _customBottomNavBar(),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '미션',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _MissionTabBar(),
              const SizedBox(height: 24),

              // ----- 도전 중 -----
              if (ongoingMissions.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '도전 중',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '2025/11/15 토',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final mission in ongoingMissions)
                  MissionOngoingCard(
                    title: mission.title,
                    description: mission.description,
                    pointText: mission.pointText,
                    onComplete: () => _completeMission(mission),
                  ),
                const SizedBox(height: 32),
              ],

              // ----- 도전 가능 -----
              const Text(
                '도전 가능',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final mission in availableMissions)
                MissionAvailableCard(
                  title: mission.title,
                  description: mission.description,
                  pointText: mission.pointText,
                  onStart: () => _startMission(mission),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- 네비게이션 바 (MapScreen 과 통일) ----------------

  Widget _customBottomNavBar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon("icon_home.png"),
          // ✅ 미션 아이콘: 현재 화면 → onTap 없음
          _navIcon("icon_mission.png"),
          // ✅ 지도 아이콘: MapScreen 으로 이동
          _navIcon(
            "icon_map.png",
            onTap: _goToMap,
          ),
          _navIcon("icon_stats.png"),
          _navIcon("icon_profile.png"),
        ],
      ),
    );
  }

  Widget _navIcon(String fileName, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        "assets/icons/$fileName",
        width: 45,
        height: 45,
      ),
    );
  }
}

// ---------------- 상단 탭바 ----------------

class _MissionTabBar extends StatelessWidget {
  _MissionTabBar({super.key});

  final Color primaryBlue = const Color(0xFF4D81E7);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE1E7F3),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: const Text(
                '오늘의 미션',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '이번주 미션',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- 카드 위젯들 ----------------

class MissionOngoingCard extends StatelessWidget {
  final String title;
  final String description;
  final String pointText;
  final VoidCallback onComplete;

  const MissionOngoingCard({
    super.key,
    required this.title,
    required this.description,
    required this.pointText,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF4D81E7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                pointText,
                style: const TextStyle(
                  fontSize: 13,
                  color: blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onComplete,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionAvailableCard extends StatelessWidget {
  final String title;
  final String description;
  final String pointText;
  final VoidCallback onStart;

  const MissionAvailableCard({
    super.key,
    required this.title,
    required this.description,
    required this.pointText,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF4D81E7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
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
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pointText,
                style: const TextStyle(
                  fontSize: 13,
                  color: blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onStart,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '도전',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
