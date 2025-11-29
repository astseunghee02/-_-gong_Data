import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Mission/Mission_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.highlightedFacilities,
  });

  final List<MapFacilityHighlight>? highlightedFacilities;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  String? _mapError;
  String? _mapStyle;
  Set<Marker> _facilityMarkers = {};
  late final List<MapFacilityHighlight> _activeFacilities;
  static const List<_MissionPreview> _missionPreviews = [
    _MissionPreview(
      title: "천안삼거리공원 2km 산책",
      subtitle: "미션 목적지까지 150m",
      point: "+500P",
    ),
    _MissionPreview(
      title: "XXX체육센터 방문",
      subtitle: "미션 목적지까지 300m",
      point: "+800P",
    ),
  ];
  static const List<MapFacilityHighlight> _defaultFacilities = [
    MapFacilityHighlight(
      name: '중구 체육센터',
      latitude: 37.564,
      longitude: 126.9975,
      description: '도보 10분 내 · 프로그램 3개',
    ),
    MapFacilityHighlight(
      name: '한강 수영장',
      latitude: 37.5296,
      longitude: 127.0745,
      description: '야외 수영 · 인기 수업',
    ),
    MapFacilityHighlight(
      name: '용산 생활체육관',
      latitude: 37.531,
      longitude: 126.982,
      description: '실내 코트 · 예약 가능',
    ),
  ];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5665, 126.9780), // Default location (Seoul)
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _activeFacilities = widget.highlightedFacilities ?? _defaultFacilities;
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      print('Failed to load map style: $e');
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
            overrides: {
              AppNavDestination.mission: (defaultItem) => BottomNavItem(
                    assetName: defaultItem.assetName,
                    isActive: defaultItem.isActive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MissionScreen(
                            initialTitle: _missionPreviews.first.title,
                            initialDescription: _missionPreviews.first.subtitle,
                            initialPoint: _missionPreviews.first.point,
                          ),
                        ),
                      );
                    },
                  ),
            },
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
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/map_title.png",
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "내 위치",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 5),
                child: Text(
                  "주변 미션을 찾아 도전해보세요",
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
                              Text(
                                '지도를 불러올 수 없습니다',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            markers: _facilityMarkers,
                            onMapCreated: (GoogleMapController controller) async {
                              try {
                                if (!_controller.isCompleted) {
                                  _controller.complete(controller);
                                }
                                if (_mapStyle != null) {
                                  await controller.setMapStyle(_mapStyle);
                                }
                                _updateFacilityMarkers(controller);
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
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "주변 미션",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < _missionPreviews.length; i++) ...[
                _missionCard(
                  title: _missionPreviews[i].title,
                  sub: _missionPreviews[i].subtitle,
                  point: _missionPreviews[i].point,
                ),
                if (i != _missionPreviews.length - 1) const SizedBox(height: 15),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionCard({
    required String title,
    required String sub,
    required String point,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 14,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 45,
              child: Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            Positioned(
              right: 15,
              top: 12,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MissionScreen(
                        initialTitle: title,
                        initialDescription: sub,
                        initialPoint: point,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 55,
                  height: 25,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C86C0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "도전",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 15,
              top: 45,
              child: Text(
                point,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3C86C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFacilityMarkers([GoogleMapController? controller]) {
    final markers = _activeFacilities
        .map(
          (facility) => Marker(
            markerId: MarkerId('facility_${facility.name}'),
            position: LatLng(facility.latitude, facility.longitude),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: facility.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        )
        .toSet();

    setState(() {
      _facilityMarkers = markers;
    });

    if (markers.isEmpty) {
      return;
    }

    Future.microtask(() async {
      final ctrl = controller ?? await _controller.future;
      if (!mounted) return;
      if (_activeFacilities.length == 1) {
        final target = LatLng(
          _activeFacilities.first.latitude,
          _activeFacilities.first.longitude,
        );
        await ctrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 15),
          ),
        );
      } else {
        await ctrl.animateCamera(
          CameraUpdate.newLatLngBounds(_calculateBounds(), 70),
        );
      }
    });
  }

  LatLngBounds _calculateBounds() {
    double minLat = _activeFacilities.first.latitude;
    double maxLat = _activeFacilities.first.latitude;
    double minLng = _activeFacilities.first.longitude;
    double maxLng = _activeFacilities.first.longitude;

    for (final facility in _activeFacilities) {
      minLat = math.min(minLat, facility.latitude);
      maxLat = math.max(maxLat, facility.latitude);
      minLng = math.min(minLng, facility.longitude);
      maxLng = math.max(maxLng, facility.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class _MissionPreview {
  final String title;
  final String subtitle;
  final String point;

  const _MissionPreview({
    required this.title,
    required this.subtitle,
    required this.point,
  });
}

class MapFacilityHighlight {
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  const MapFacilityHighlight({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}
