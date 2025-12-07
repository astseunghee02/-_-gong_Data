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
import '../../services/auth_service.dart';
import '../../services/mission_service.dart';
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

  // 미션 통계
  int _ongoingMissionCount = 0;
  int _weeklyCompleted = 0;
  int _totalCompleted = 0;
  bool _isLoadingMissions = false;
  String? _missionError;

  final MissionService _missionService = MissionService.instance;
  List<MissionModel> _availableMissions = [];
  List<MissionModel> _ongoingMissions = [];

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
      await _refreshMissionsAndStats(position);

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
      await _refreshMissionsAndStats(null);
    }
  }

  Future<void> _refreshMissionsAndStats(Position? position) async {
    setState(() {
      _isLoadingMissions = true;
      _missionError = null;
    });

    final token = await AuthService.getToken();
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (token == null || baseUrl == null || baseUrl.isEmpty) {
      if (!mounted) return;
      setState(() {
        _missionError = '로그인이 필요합니다. 다시 로그인해주세요.';
        _isLoadingMissions = false;
      });
      return;
    }

    try {
      if (position != null) {
        await _missionService.generateMissions(
          lat: position.latitude,
          lon: position.longitude,
        );
      }

      final available = await _missionService.fetchAvailableMissions();
      final ongoing = await _missionService.fetchOngoingMissions();
      await _loadMissionStats();

      if (!mounted) return;
      setState(() {
        _availableMissions = available;
        _ongoingMissions = ongoing;
      });
    } catch (e) {
      print('❌ 미션 데이터 로드 오류: $e');
      if (!mounted) return;
      setState(() {
        _missionError = '미션 정보를 불러오지 못했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMissions = false;
      });
    }
  }

  Future<void> _fetchNearbyPlaces(Position position) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      print('❌ API_BASE_URL이 설정되지 않았습니다.');
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
      print('📍 주변 장소 API 호출: $uri');

      final res = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('서버 응답 시간 초과');
        },
      );

      print('📡 응답 상태 코드: ${res.statusCode}');
      print('📡 응답 본문: ${res.body}');

      if (res.statusCode != 200) {
        setState(() {
          _nearbyError = '주변 장소 조회 실패 (${res.statusCode})';
          _isLoadingNearby = false;
        });
        return;
      }

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      print('✅ 주변 장소 ${data.length}개 로드됨');

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
      print('❌ 주변 장소 불러오기 오류: $e');
      setState(() {
        _nearbyError = '서버 연결 실패: ${e.toString()}';
        _isLoadingNearby = false;
      });
    }
  }

  Future<void> _loadMissionStats() async {
    final stats = await _missionService.fetchMissionStats();
    if (!mounted || stats == null) return;

    setState(() {
      _ongoingMissionCount = stats.ongoing;
      _weeklyCompleted = stats.weeklyCompleted;
      _totalCompleted = stats.totalCompleted;
    });
  }

  void _focusOnPlace(_NearbyPlace place) {
    final target = LatLng(place.lat, place.lon);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target, 16),
    );
  }

  Future<void> _handleStartMission(MissionModel mission) async {
    final started = await _missionService.startMission(
      mission.missionId,
      position: _currentPosition,
    );

    if (started == null) {
      if (!mounted) return;
      setState(() {
        _missionError = '미션을 시작하지 못했습니다. 잠시 후 다시 시도해주세요.';
      });
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('미션을 시작했어요!')),
    );
    await _refreshMissionsAndStats(_currentPosition);
  }

  Future<void> _handleCompleteMission(MissionModel mission) async {
    final result = await _missionService.completeMission(
      mission.missionId,
      position: _currentPosition,
    );

    if (result == null) {
      if (!mounted) return;
      setState(() {
        _missionError = '미션을 완료하지 못했습니다. 장소에 더 가까이 가거나 다시 시도해주세요.';
      });
      return;
    }

    UserProgressController.instance.addMissionCompletion(
      points: result.pointsEarned,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('미션 완료! +${result.pointsEarned}P 획득')),
    );
    await _refreshMissionsAndStats(_currentPosition);
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
                child: _MissionStatsPanel(
                  ongoing: _ongoingMissionCount,
                  weeklyCompleted: _weeklyCompleted,
                  totalCompleted: _totalCompleted,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MissionFeaturePanel(
                  ongoingMissions: _ongoingMissions,
                  availableMissions: _availableMissions,
                  isLoading: _isLoadingMissions,
                  errorMessage: _missionError,
                  onStart: _handleStartMission,
                  onComplete: _handleCompleteMission,
                  onRefresh: () => _refreshMissionsAndStats(_currentPosition),
                ),
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
  final int ongoing;
  final int weeklyCompleted;
  final int totalCompleted;

  const _MissionStatsPanel({
    required this.ongoing,
    required this.weeklyCompleted,
    required this.totalCompleted,
  });

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
              value: formatter.format(ongoing),
              label: '진행중',
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(weeklyCompleted),
              label: '이번주 완료',
              showDivider: true,
            ),
          ),
          Expanded(
            child: _MissionStatTile(
              value: formatter.format(totalCompleted),
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

class _MissionFeaturePanel extends StatefulWidget {
  final List<MissionModel> ongoingMissions;
  final List<MissionModel> availableMissions;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function(MissionModel) onStart;
  final Future<void> Function(MissionModel) onComplete;
  final Future<void> Function() onRefresh;

  const _MissionFeaturePanel({
    super.key,
    required this.ongoingMissions,
    required this.availableMissions,
    required this.isLoading,
    required this.errorMessage,
    required this.onStart,
    required this.onComplete,
    required this.onRefresh,
  });

  @override
  State<_MissionFeaturePanel> createState() => _MissionFeaturePanelState();
}

class _MissionFeaturePanelState extends State<_MissionFeaturePanel> {
  _MissionTab _selectedTab = _MissionTab.today;
  bool _isActionInProgress = false;

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);
    await action();
    if (mounted) {
      setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _MissionFeatureTabBar(
          selected: _selectedTab,
          onChanged: (tab) {
            if (_selectedTab == tab) return;
            setState(() => _selectedTab = tab);
          },
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 12),
          _MissionEmptyCard(message: widget.errorMessage!),
        ],
        const SizedBox(height: 16),
        if (_selectedTab == _MissionTab.today)
          ..._buildOngoingSection()
        else
          ..._buildWeeklySection(),
      ],
    );
  }

  List<Widget> _buildOngoingSection() {
    final missions = widget.ongoingMissions;
    final isLoading = widget.isLoading && missions.isEmpty;

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
          Row(
            children: [
              IconButton(
                onPressed: () => _runAction(widget.onRefresh),
                icon: const Icon(Icons.refresh, size: 20),
                color: const Color(0xFF3C86C0),
                tooltip: '새로고침',
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
        ],
      ),
      const SizedBox(height: 12),
      if (isLoading)
        const _MissionLoadingCard(message: '도전 중인 미션을 불러오는 중...')
      else if (missions.isEmpty)
        _MissionEmptyCard(message: '도전 중인 미션이 없습니다')
      else
        ...missions.map(
          (mission) => _MissionOngoingCard(
            data: mission,
            isBusy: _isActionInProgress,
            onComplete: () => _runAction(() => widget.onComplete(mission)),
          ),
        ),
      const SizedBox(height: 32),
    ];
  }

  List<Widget> _buildWeeklySection() {
    final missions = widget.availableMissions;
    final isLoading = widget.isLoading && missions.isEmpty;

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '도전 가능한 미션',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: () => _runAction(widget.onRefresh),
            icon: const Icon(Icons.refresh, size: 20),
            color: const Color(0xFF3C86C0),
            tooltip: '새로고침',
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (isLoading)
        const _MissionLoadingCard(message: '도전 가능한 미션을 불러오는 중...')
      else if (missions.isEmpty)
        _MissionEmptyCard(message: '도전 가능한 미션이 없습니다')
      else
        ...missions.map(
          (mission) => _MissionAvailableCard(
            data: mission,
            isBusy: _isActionInProgress,
            onStart: () => _runAction(() => widget.onStart(mission)),
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

class _MissionOngoingCard extends StatelessWidget {
  final MissionModel data;
  final VoidCallback? onComplete;
  final bool isBusy;

  const _MissionOngoingCard({
    required this.data,
    this.onComplete,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool canComplete = onComplete != null && !isBusy;
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
          const SizedBox(height: 10),
          if (data.placeName != null || data.distanceKm != null)
            Row(
              children: [
                const Icon(Icons.place, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      if (data.placeName != null) data.placeName!,
                      if (data.distanceKm != null)
                        '${data.distanceKm!.toStringAsFixed(2)} km'
                    ].join(' • '),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E7F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '진행중',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: blue,
                    ),
                  ),
                ),
              ],
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
                child: isBusy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
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
  final MissionModel data;
  final VoidCallback onStart;
  final bool isBusy;

  const _MissionAvailableCard({
    required this.data,
    required this.onStart,
    this.isBusy = false,
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
                if (data.placeName != null || data.address != null || data.distanceKm != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            if (data.placeName != null) data.placeName!,
                            if (data.distanceKm != null)
                              '${data.distanceKm!.toStringAsFixed(2)} km'
                          ].join(' • '),
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
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
                onTap: isBusy ? null : onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBusy ? Colors.grey : blue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
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

class _MissionLoadingCard extends StatelessWidget {
  final String message;

  const _MissionLoadingCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            message,
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
