import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 온보딩 페이지 정보
  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      backgroundColor: AppColors.background,
      title: '당신의 운동을 더 재미있게!',
      subtitle: '공공체육시설 정보와 운동 데이터를 기반으로\n매일 달라지는 운동 미션을 제공합니다',
      isSplash: true,
    ),
    _OnboardingPageData(
      backgroundColor: AppColors.background,
      title: '운동할수록 캐릭터가 성장해요',
      subtitle: '걸음수·러닝·운동 인증을 하면 당신의 캐릭터가 점점 강해집니다.!',
    ),
    _OnboardingPageData(
      backgroundColor: AppColors.background,
      title: '오늘 할 운동을 추천받고, 인증하세요',
      subtitle:
      '위치 기반 루트, 공공체육시설 프로그램 그리고 GPS로 간단 인증!',
    ),
    _OnboardingPageData(
      backgroundColor: AppColors.background,
      title: 'Work-Flow, 포리와 함께 운동을 시작해보세요',
      subtitle:
      '오늘의 운동 완료 → 포인트 적립 → 레벨업!',
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage == _pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ------ 상단 여백 / 뒤로가기(2페이지 이후) ------
            if (!page.isSplash)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _currentPage > 0
                      ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Color(0xFF3C86C0),
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              )
            else
              const SizedBox(height: 16),

            // ------ PageView 영역 ------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _pages[index];

                  // 스플래시 페이지
                  if (data.isSplash) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            'assets/images/Lv01_pori.png',
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.subtitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  // 일반 온보딩 페이지
                  return Container(
                    color: data.backgroundColor,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ------ 인디케이터 + 버튼 ------
            Container(
              color: AppColors.background,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 인디케이터 (스플래시도 포함해서 4개)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 18 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF3C86C0)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 버튼 (마지막만 GET STARTED)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        page.isLast ? 'GET STARTED' : 'NEXT',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final bool isSplash;
  final bool isLast;

  _OnboardingPageData({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    this.isSplash = false,
    this.isLast = false,
  });
}
