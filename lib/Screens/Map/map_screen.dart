import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../Mission/mission_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  String? _mapError;
  String? _mapStyle;
<<<<<<< HEAD
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
=======
>>>>>>> a0ed8f4219256d64949a3876ae506c8ecd205bd3

  static const CameraPosition _kDefaultPosition = CameraPosition(
    target: LatLng(37.5665, 126.9780), // Default location (Seoul)
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
<<<<<<< HEAD
    _getCurrentLocation();
=======
>>>>>>> a0ed8f4219256d64949a3876ae506c8ecd205bd3
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
    } catch (e) {
      print('Failed to load map style: $e');
    }
  }

<<<<<<< HEAD
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _mapError = '위치 서비스가 비활성화되어 있습니다';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _mapError = '위치 권한이 거부되었습니다';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _mapError = '위치 권한이 영구적으로 거부되었습니다';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _mapError = '위치를 가져올 수 없습니다: $e';
        _isLoadingLocation = false;
      });
    }
  }

=======
>>>>>>> a0ed8f4219256d64949a3876ae506c8ecd205bd3
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: _customBottomNavBar(),
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
                            initialCameraPosition: _currentPosition != null
                                ? CameraPosition(
                                    target: _currentPosition!,
                                    zoom: 16.0,
                                  )
                                : _kDefaultPosition,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            compassEnabled: true,
                            mapToolbarEnabled: false,
                            onMapCreated: (GoogleMapController controller) async {
                              try {
                                if (!_controller.isCompleted) {
                                  _controller.complete(controller);
                                }
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
              _missionCard(
                title: "천안삼거리공원 2km 산책",
                sub: "미션 목적지까지 150m",
                point: "+500P",
              ),
              const SizedBox(height: 15),
              _missionCard(
                title: "XXX체육센터 방문",
                sub: "미션 목적지까지 300m",
                point: "+800P",
              ),
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
                    color: Colors.black,
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
                  color: Color(0xFF4D81E7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          _navIcon(
            "icon_mission.png",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MissionScreen(), // 그냥 미션 화면
                ),
              );
            },
          ),
          _navIcon("icon_map.png"), // 현재 화면
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
