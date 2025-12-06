import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../data/user_progress_controller.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../services/location_service.dart';
import '../Mission/Mission_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _mapError;
  String? _mapStyle;
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  List<_NearbyPlace> _nearbyPlaces = [];
  bool _isLoadingNearby = false;
  String? _nearbyError;

  // 초기 카메라 위치 (서울 기본값)
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 14.4746,
  );

  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      debugPrint('Failed to load map style: ');
    }
  }

  /// 현재 위치 가져오기 및 지도 이동
  Future<void> _loadCurrentLocation() async {
    print('📍 현재 위치를 가져오는 중...');

    final position = await _locationService.getCurrentLocation();

    if (position != null) {
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        );
      });

      // 터미널에 경도/위도 출력
      print('✅ 위치 정보 수신 완료!');
      print('📌 위도(Latitude): ${position.latitude}');
      print('📌 경도(Longitude): ${position.longitude}');
      print('🎯 정확도(Accuracy): ${position.accuracy}m');
      print('⏰ 시간: ${DateTime.now()}');
      print('─' * 50);

      await _fetchNearbyPlaces(position);

      // 지도 카메라를 현재 위치로 이동
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        );
      }
    } else {
      setState(() {
        _isLoadingLocation = false;
      });
      print('❌ 위치 정보를 가져올 수 없습니다.');
      print('⚠️  위치 권한을 확인하거나 GPS를 활성화해주세요.');
    }
  }

  Future<void> _fetchNearbyPlaces(Position position) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      setState(() {
        _nearbyError = 'API_BASE_URL이 설정되지 않았습니다.';
      });
      return;
    }

    setState(() {
      _isLoadingNearby = true;
      _nearbyError = null;
    });

    try {
      final uri = Uri.parse(
        '$baseUrl/api/nearby?lat=${position.latitude}&lon=${position.longitude}&limit=5',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        setState(() {
          _nearbyError = '주변 장소 조회 실패 (${res.statusCode})';
          _isLoadingNearby = false;
        });
        return;
      }

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      final places = data
          .map((e) => _NearbyPlace.fromJson(e as Map<String, dynamic>))
          .toList();

      final markers = places
          .map(
            (p) => Marker(
              markerId: MarkerId('nearby_${p.id ?? p.name}_${p.lat}_${p.lon}'),
              position: LatLng(p.lat, p.lon),
              infoWindow: InfoWindow(
                title: p.name,
                snippet: '${p.distance} km',
              ),
            ),
          )
          .toSet();

      setState(() {
        _nearbyPlaces = places;
        _markers
          ..clear()
          ..addAll(markers);
        _isLoadingNearby = false;
      });
    } catch (e) {
      setState(() {
        _nearbyError = '주변 장소 불러오기 중 오류가 발생했습니다.';
        _isLoadingNearby = false;
      });
    }
  }

  void _focusOnPlace(_NearbyPlace place) {
    final target = LatLng(place.lat, place.lon);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          child: Stack(
                            children: [
                              GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: _initialCameraPosition,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                zoomControlsEnabled: false,
                                compassEnabled: true,
                                mapToolbarEnabled: false,
                                markers: _markers,
                                onMapCreated: (GoogleMapController controller) async {
                                  _mapController = controller;
                                  try {
                                    if (_mapStyle != null) {
                                      await controller.setMapStyle(_mapStyle);
                                    }
                                    // 위치를 이미 가져왔다면 카메라 이동
                                    if (_currentPosition != null) {
                                      controller.animateCamera(
                                        CameraUpdate.newCameraPosition(_initialCameraPosition),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _mapError = e.toString();
                                    });
                                  }
                                },
                              ),
                              // 위치 로딩 중 표시
                              if (_isLoadingLocation)
                                Container(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          '현재 위치를 찾는 중...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // 새로고침 버튼
                              Positioned(
                                top: 10,
                                right: 10,
                                child: FloatingActionButton.small(
                                  onPressed: _loadCurrentLocation,
                                  backgroundColor: Colors.white,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Color(0xFF3C86C0),
                                    ),
                                  ),
                                ),
                              if (_nearbyError != null)
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  right: 12,
                                  child: _NearbyStatusBanner(
                                    message: _nearbyError!,
                                    isError: true,
                                  ),
                                ),
                              if (_isLoadingNearby && !_isLoadingLocation)
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  right: 12,
                                  child: const _NearbyStatusBanner(
                                    message: '주변 장소를 불러오는 중...',
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _NearbyList(
                  places: _nearbyPlaces,
                  onTap: (place) => _focusOnPlace(place),
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

class _NearbyList extends StatelessWidget {
  final List<_NearbyPlace> places;
  final ValueChanged<_NearbyPlace> onTap;

  const _NearbyList({
    required this.places,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주변 추천 5곳',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (places.isEmpty)
          Container(
            width: double.infinity,
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
            child: const Text(
              '근처 정보를 불러오면 여기에서 보여줄게요.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          )
        else
          Column(
            children: places
                .map(
                  (p) => _NearbyTile(
                    place: p,
                    onTap: () => onTap(p),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _NearbyTile extends StatelessWidget {
  final _NearbyPlace place;
  final VoidCallback onTap;

  const _NearbyTile({
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF3C86C0),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.place,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${place.distance} km',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyStatusBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _NearbyStatusBanner({
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade400 : Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.location_on,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
              value: formatter.format(data.ongoing),
              label: '진행중',
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(data.weeklyCompleted),
              label: '이번주 완료',
              showDivider: true,
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(data.totalCompleted),
              label: '총 완료',
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
  final int ongoing;
  final int weeklyCompleted;
  final int totalCompleted;

  const _MissionStats({
    required this.ongoing,
    required this.weeklyCompleted,
    required this.totalCompleted,
  });
}

const _MissionStats _missionStats = _MissionStats(
  ongoing: 5,
  weeklyCompleted: 3,
  totalCompleted: 48,
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

  void _handleMissionComplete(_MissionProgressItem mission) {
    UserProgressController.instance
        .addMissionCompletion(points: mission.pointValue);
    setState(() {
      _ongoingMissions.remove(mission);
    });
  }

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
                    ? () => _handleMissionComplete(mission)
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
                  pointValue: mission.pointValue,
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

class _NearbyPlace {
  final int? id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final double distance;

  _NearbyPlace({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.distance,
  });

  factory _NearbyPlace.fromJson(Map<String, dynamic> json) {
    return _NearbyPlace(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
    );
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
  final int pointValue;
  final double progress;

  const _MissionProgressItem({
    required this.title,
    required this.description,
    required this.pointText,
    required this.pointValue,
    this.progress = 0.2,
  });
}

class _MissionItem {
  final String title;
  final String description;
  final String pointText;
  final int pointValue;

  const _MissionItem({
    required this.title,
    required this.description,
    required this.pointText,
    required this.pointValue,
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
    pointValue: 500,
    progress: 0.6,
  ),
];

const List<_MissionItem> _defaultAvailableMissions = [
  _MissionItem(
    title: '공원 3곳 탐방하기',
    description: '천안 동남구 내 공원 3곳 도달',
    pointText: '+750P',
    pointValue: 750,
  ),
  _MissionItem(
    title: '인근 체육시설 방문',
    description: '인근 공원·체육시설 중 1곳 도착',
    pointText: '+900P',
    pointValue: 900,
  ),
];
