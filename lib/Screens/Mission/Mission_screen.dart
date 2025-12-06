import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/community_sections.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Map/map_screen.dart';

import '../../recommend_backend/fit_recommend.dart';
import '../../recommend_backend/recommendation_models.dart';
import '../../widgets/recommendation_section_from_api.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final RecommendService _service = RecommendService();
  late Future<RecommendationResponse> _futureRecommend;

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
              FacilitySection(
                facilities: defaultFacilities,
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
