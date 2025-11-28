import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class Mission {
  final String title;
  final String description;
  final String pointText;

  const Mission({
    required this.title,
    required this.description,
    required this.pointText,
  });
}

enum MissionTab { today, weekly }

class _MissionProgress {
  final Mission mission;
  final double progress;

  const _MissionProgress({
    required this.mission,
    this.progress = 0.2,
  });
}

const List<Mission> _defaultMissionPool = [
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
  final List<_MissionProgress> _ongoingMissions = [];
  late List<Mission> _availableMissions;
  MissionTab _selectedTab = MissionTab.today;

  @override
  void initState() {
    super.initState();

    _availableMissions = List<Mission>.from(_defaultMissionPool);

    // 지도 화면에서 "도전" 눌러서 넘어온 미션이 있으면
    if (widget.initialTitle != null &&
        widget.initialDescription != null &&
        widget.initialPoint != null) {
      final fromMap = Mission(
        title: widget.initialTitle!,
        description: widget.initialDescription!,
        pointText: widget.initialPoint!,
      );
      _availableMissions.removeWhere((mission) => mission.title == fromMap.title);
      _ongoingMissions.add(_MissionProgress(mission: fromMap));
    }
  }

  // 도전 가능 → 도전 중
  void _startMission(Mission mission) {
    setState(() {
      _availableMissions.remove(mission);
      _ongoingMissions.add(_MissionProgress(mission: mission));
    });
  }

  // 도전 중 → 완료(리스트에서 제거)
  void _completeMission(_MissionProgress mission) {
    if (mission.progress < 1.0) return;
    setState(() {
      _ongoingMissions.remove(mission);
    });
  }

  void _onTabChanged(MissionTab tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ✅ MapScreen 과 동일 스타일의 네비게이션 바
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          items: buildAppBottomNavItems(
            context,
            AppNavDestination.mission,
          ),
        ),
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
              _MissionTabBar(
                selected: _selectedTab,
                onTabChanged: _onTabChanged,
              ),
              const SizedBox(height: 24),

              ...(_selectedTab == MissionTab.today
                  ? _buildOngoingSection()
                  : _buildWeeklySection()),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOngoingSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '도전 중',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            DateFormat('yyyy/MM/dd').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (_ongoingMissions.isEmpty)
        _buildEmptyState('도전 중인 미션이 없습니다')
      else
        ..._ongoingMissions.map(
          (mission) => MissionOngoingCard(
            title: mission.mission.title,
            description: mission.mission.description,
            pointText: mission.mission.pointText,
            progress: mission.progress,
            onComplete: () => _completeMission(mission),
          ),
        ),
      const SizedBox(height: 32),
    ];
  }


  List<Widget> _buildWeeklySection() {
    return [
      const Text(
        '도전 가능',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      if (_availableMissions.isEmpty)
        _buildEmptyState('도전 가능한 미션이 없습니다')
      else
        ..._availableMissions.map(
          (mission) => MissionAvailableCard(
            title: mission.title,
            description: mission.description,
            pointText: mission.pointText,
            onStart: () => _startMission(mission),
          ),
        ),
    ];
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}

// ---------------- 상단 탭바 ----------------

class _MissionTabBar extends StatelessWidget {
  const _MissionTabBar({
    super.key,
    required this.selected,
    required this.onTabChanged,
  });

  final MissionTab selected;
  final ValueChanged<MissionTab> onTabChanged;

  static const Color primaryBlue = Color(0xFF3C86C0);

  @override
  Widget build(BuildContext context) {
    final bool isToday = selected == MissionTab.today;
    final bool isWeekly = selected == MissionTab.weekly;

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
            child: GestureDetector(
              onTap: () => onTabChanged(MissionTab.today),
              child: Container(
                decoration: BoxDecoration(
                  color: isToday ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '오늘의 미션',
                  style: TextStyle(
                    color: isToday ? Colors.white : primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(MissionTab.weekly),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isWeekly ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '이번주 미션',
                  style: TextStyle(
                    color: isWeekly ? Colors.white : primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

// ---------------- 카드 위젯들 ----------------

class MissionOngoingCard extends StatelessWidget {
  final String title;
  final String description;
  final String pointText;
  final double progress;
  final VoidCallback onComplete;

  const MissionOngoingCard({
    super.key,
    required this.title,
    required this.description,
    required this.pointText,
    this.progress = 0.2,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF3C86C0);
    const Color disabledGrey = Color(0xFFB7C0CC);
    final bool canComplete = progress >= 1.0;

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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: const Color(0xFFE1E7F3),
              valueColor: const AlwaysStoppedAnimation<Color>(blue),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: canComplete ? onComplete : null,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: canComplete ? blue : disabledGrey,
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
    const Color blue = Color(0xFF3C86C0);

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
