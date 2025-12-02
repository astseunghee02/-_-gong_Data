import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF5BBFF8),
      title: 'Drops Water Tracker',
      subtitle: 'Stay hydrated and track your daily water intake',
      isSplash: true,
    ),
    _OnboardingPageData(
      backgroundColor: Colors.white,
      title: 'Track your daily water\nintake with Us.',
      subtitle: 'Achieve your hydration goals with a simple tap!',
    ),
    _OnboardingPageData(
      backgroundColor: Colors.white,
      title: 'Smart Reminders\nTailored to You',
      subtitle:
      'Quick and easy to set your hydration goal\nand track your daily intake progress.',
    ),
    _OnboardingPageData(
      backgroundColor: Colors.white,
      title: 'Easy to Use – Drink, Tap, Repeat',
      subtitle:
      'Staying hydrated every day is easy\nwith Drops Water Tracker.',
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
                      color: Colors.lightBlue,
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
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.opacity, // 물방울 아이콘
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
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
                            color: Colors.grey,
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
              color: page.isSplash ? const Color(0xFF5BBFF8) : Colors.white,
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
                              ? Colors.lightBlue
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
                        backgroundColor: const Color(0xFF5BBFF8),
                        foregroundColor: Colors.white,
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
