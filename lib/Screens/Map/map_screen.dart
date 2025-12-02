import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Mission/Mission_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _mapError;
  String? _mapStyle;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      debugPrint('Failed to load map style: ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          items: buildAppBottomNavItems(
            context,
            AppNavDestination.map,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: const Text(
                  '미션',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Text(
                  '주변 미션을 찾아 도전해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 380,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: _mapError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 10),
                              const Text(
                                '지도 로딩 실패',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _mapError!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _kGooglePlex,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            compassEnabled: true,
                            mapToolbarEnabled: false,
                            onMapCreated: (GoogleMapController controller) async {
                              try {
                                if (_mapStyle != null) {
                                  await controller.setMapStyle(_mapStyle);
                                }
                              } catch (e) {
                                setState(() {
                                  _mapError = e.toString();
                                });
                              }
                            },
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MissionStatsPanel(data: _missionStats),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _MissionFeaturePanel(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionStatsPanel extends StatelessWidget {
  final _MissionStats data;

  const _MissionStatsPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(data.completed),
              label: '완료',
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(data.ongoing),
              label: '진행중',
              showDivider: true,
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(data.points),
              label: '포인트',
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionStatTile extends StatelessWidget {
  final String value;
  final String label;
  final bool showDivider;

  const _MissionStatTile({
    required this.value,
    required this.label,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showDivider
          ? const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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

class _MissionStats {
  final int completed;
  final int ongoing;
  final int points;

  const _MissionStats({
    required this.completed,
    required this.ongoing,
    required this.points,
  });
}

const _MissionStats _missionStats = _MissionStats(
  completed: 12,
  ongoing: 5,
  points: 2450,
);

class _MissionFeaturePanel extends StatefulWidget {
  const _MissionFeaturePanel({super.key});

  @override
  State<_MissionFeaturePanel> createState() => _MissionFeaturePanelState();
}

class _MissionFeaturePanelState extends State<_MissionFeaturePanel> {
  _MissionTab _selectedTab = _MissionTab.today;
  final List<_MissionProgressItem> _ongoingMissions =
      List<_MissionProgressItem>.from(_defaultOngoingMissions);
  final List<_MissionItem> _availableMissions =
      List<_MissionItem>.from(_defaultAvailableMissions);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   '??',
        //   style: TextStyle(
        //     fontSize: 24,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
        const SizedBox(height: 16),
        _MissionFeatureTabBar(
          selected: _selectedTab,
          onChanged: (tab) {
            if (_selectedTab == tab) return;
            setState(() => _selectedTab = tab);
          },
        ),
        const SizedBox(height: 24),
        if (_selectedTab == _MissionTab.today)
          ..._buildOngoingSection()
        else
          ..._buildWeeklySection(),
      ],
    );
  }

  List<Widget> _buildOngoingSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '도전 중인 미션',
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
      const SizedBox(height: 12),
      if (_ongoingMissions.isEmpty)
        _MissionEmptyCard(message: '도전 중인 미션이 없습니다')
      else
        ..._ongoingMissions.map(
          (mission) => _MissionOngoingCard(
            data: mission,
            onComplete: mission.progress >= 1.0
                ? () => setState(() {
                      _ongoingMissions.remove(mission);
                    })
                : null,
          ),
        ),
      const SizedBox(height: 32),
    ];
  }

  List<Widget> _buildWeeklySection() {
    return [
      const Text(
        '도전 가능한 미션',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      if (_availableMissions.isEmpty)
        _MissionEmptyCard(message: '도전 가능한 미션이 없습니다')
      else
        ..._availableMissions.map(
          (mission) => _MissionAvailableCard(
            data: mission,
            onStart: () => setState(() {
              _availableMissions.remove(mission);
              _ongoingMissions.add(
                _MissionProgressItem(
                  title: mission.title,
                  description: mission.description,
                  pointText: mission.pointText,
                  progress: 0.1,
                ),
              );
              _selectedTab = _MissionTab.today;
            }),
          ),
        ),
    ];
  }
}

enum _MissionTab { today, weekly }

class _MissionFeatureTabBar extends StatelessWidget {
  final _MissionTab selected;
  final ValueChanged<_MissionTab> onChanged;

  const _MissionFeatureTabBar({
    required this.selected,
    required this.onChanged,
  });

  static const Color primaryBlue = Color(0xFF3C86C0);

  @override
  Widget build(BuildContext context) {
    final bool isToday = selected == _MissionTab.today;
    final bool isWeekly = selected == _MissionTab.weekly;

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
              onTap: () => onChanged(_MissionTab.today),
              child: Container(
                decoration: BoxDecoration(
                  color: isToday ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '도전중',
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
              onTap: () => onChanged(_MissionTab.weekly),
              child: Container(
                decoration: BoxDecoration(
                  color: isWeekly ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '도전 가능',
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

class _MissionProgressItem {
  final String title;
  final String description;
  final String pointText;
  final double progress;

  const _MissionProgressItem({
    required this.title,
    required this.description,
    required this.pointText,
    this.progress = 0.2,
  });
}

class _MissionItem {
  final String title;
  final String description;
  final String pointText;

  const _MissionItem({
    required this.title,
    required this.description,
    required this.pointText,
  });
}

class _MissionOngoingCard extends StatelessWidget {
  final _MissionProgressItem data;
  final VoidCallback? onComplete;

  const _MissionOngoingCard({required this.data, this.onComplete});

  @override
  Widget build(BuildContext context) {
    final bool canComplete = (data.progress >= 1.0) && onComplete != null;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                data.pointText,
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
            data.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: data.progress.clamp(0.0, 1.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: canComplete ? blue : const Color(0xFFB7C0CC),
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

class _MissionAvailableCard extends StatelessWidget {
  final _MissionItem data;
  final VoidCallback onStart;

  const _MissionAvailableCard({
    required this.data,
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
                  data.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.pointText,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

class _MissionEmptyCard extends StatelessWidget {
  final String message;

  const _MissionEmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
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

const List<_MissionProgressItem> _defaultOngoingMissions = [
  _MissionProgressItem(
    title: '~~~ 30분 산책',
    description: '~~~ 근처에서 30분 이상 이동하기',
    pointText: '+500P',
    progress: 0.6,
  ),
];

const List<_MissionItem> _defaultAvailableMissions = [
  _MissionItem(
    title: '공원 3곳 탐방하기',
    description: '천안 동남구 내 공원 3곳 도달',
    pointText: '+750P',
  ),
  _MissionItem(
    title: '인근 체육시설 방문',
    description: '인근 공원·체육시설 중 1곳 도착',
    pointText: '+900P',
  ),
];
