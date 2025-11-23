import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------ 하단 네비게이션 바 (항상 아래 고정) ------------------
      bottomNavigationBar: SafeArea(
        top: false,
        child: _customBottomNavBar(),
      ),

      // ------------------ 메인 화면 내용 ------------------
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------- 상단 타이틀 영역 ----------
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

              // ---------- 지도 구간 ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 380,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text("여기에 지도 API 들어감"),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ---------- 주변 미션 ----------
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

              const SizedBox(height: 100),  // 네비바 공간 확보용
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ 미션 카드 위젯 ------------------
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

  // ------------------ 커스텀 네비게이션 바 ------------------
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
          _navIcon("icon_mission.png"),
          _navIcon("icon_map.png"),  // 현재 페이지
          _navIcon("icon_stats.png"),
          _navIcon("icon_profile.png"),
        ],
      ),
    );
  }

  Widget _navIcon(String fileName) {
    return Image.asset(
      "assets/icons/$fileName",
      width: 45,
      height: 45,
    );
  }
}
