import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/app_bottom_nav_items.dart';
import '../../widgets/community_sections.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../Map/map_screen.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

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
              const Text(
                '운동 가이드',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
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
              const ProgramSection(programs: defaultPrograms),
              const SizedBox(height: 16),
              const RecommendationSection(
                recommendations: defaultAgeRecommendations,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
