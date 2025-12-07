import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/community_sections.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Map/map_screen.dart';

import '../../recommend_backend/fit_recommend.dart';
import '../../recommend_backend/recommendation_models.dart';
import '../../widgets/recommendation_section_from_api.dart';
import '../../services/place_service.dart';
import '../../services/location_service.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final RecommendService _service = RecommendService();
  late Future<RecommendationResponse> _futureRecommend;
  final LocationService _locationService = LocationService();
  final PlaceService _placeService = PlaceService.instance;

  List<FacilityInfo> _facilities = defaultFacilities;
  bool _isLoadingFacilities = true;
  String? _facilityError;

  @override
  void initState() {
    super.initState();

    // ⚠️ TODO: 실제 사용자 정보(나이, 성별, 키, 체중)를 대입해야 함
    // 일단 테스트용 하드코딩
    _futureRecommend = _service.getRecommendations(
      ageGroup: "20대",
      sex: "F",
      heightCm: 162,
      weightKg: 80,
    );
    _loadNearbyFacilities();
  }

  Future<void> _loadNearbyFacilities() async {
    setState(() {
      _isLoadingFacilities = true;
      _facilityError = null;
    });

    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _facilityError = '현재 위치를 가져올 수 없습니다. 위치 권한을 확인해주세요.';
        _isLoadingFacilities = false;
      });
      return;
    }

    final places = await _placeService.fetchNearbyPlaces(position: position);
    if (!mounted) return;

    if (places.isEmpty) {
      setState(() {
        _facilityError = '주변 공공체육시설을 찾지 못했습니다.';
        _isLoadingFacilities = false;
      });
      return;
    }

    setState(() {
      _facilities = places
          .map(
            (p) => FacilityInfo(
              name: p.name,
              distance: '${p.distance.toStringAsFixed(2)}km',
              rating: 4.5, // TODO: 실제 평점 데이터가 있으면 적용
              programs: 0,
            ),
          )
          .toList();
      _isLoadingFacilities = false;
    });
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
            AppNavDestination.mission,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------
              // 상단 제목
              // -------------------------------
              const Text(
                '운동 가이드',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // -------------------------------
              // 기존 시설 카드
              // -------------------------------
              _FacilitySectionWrapper(
                facilities: _facilities,
                isLoading: _isLoadingFacilities,
                error: _facilityError,
                onRefresh: _loadNearbyFacilities,
                onViewMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // -------------------------------
              // 프로그램 카드
              // -------------------------------
              const ProgramSection(programs: defaultPrograms),
              const SizedBox(height: 16),

              // -------------------------------
              // 🔥 추천 API 결과 표시하는 부분
              // -------------------------------
              FutureBuilder<RecommendationResponse>(
                future: _futureRecommend,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "운동 추천 정보를 불러오지 못했습니다.\n${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  return RecommendationSectionFromApi(
                    userName: "ㅇㅇㅇ", // TODO: 로그인 정보로 대체
                    bmi: data.bmi,
                    difficulty: data.difficulty,
                    levels: data.levels,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacilitySectionWrapper extends StatelessWidget {
  final List<FacilityInfo> facilities;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onViewMore;

  const _FacilitySectionWrapper({
    required this.facilities,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FacilitySection(
            facilities: facilities,
            onViewMore: onViewMore,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFB26A00)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Color(0xFF8A5A00), fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18, color: Color(0xFFB26A00)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return FacilitySection(
      facilities: facilities,
      onViewMore: onViewMore,
    );
  }
}
