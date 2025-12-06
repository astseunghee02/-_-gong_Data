import 'package:flutter/material.dart';

import '../Screens/Home/home_screen.dart';
import '../Screens/Map/map_screen.dart';
import '../Screens/Mission/Mission_screen.dart';
import '../Screens/Setting/Setting_screen.dart';
import '../Screens/UserStatics/StatusScreen.dart';
import 'custom_bottom_nav_bar.dart';

enum AppNavDestination { map, mission, home, user, setting }

List<BottomNavItem> buildAppBottomNavItems(
  BuildContext context,
  AppNavDestination current, {
  Map<AppNavDestination, BottomNavItem Function(BottomNavItem defaultItem)>?
      overrides,
}) {
  final entries = <MapEntry<AppNavDestination, BottomNavItem>>[
    MapEntry(
      AppNavDestination.map,
      _buildItem(
        context: context,
        destination: AppNavDestination.map,
        current: current,
        assetName: "Map_Icon.svg",
        builder: () => const MapScreen(),
      ),
    ),
    MapEntry(
      AppNavDestination.mission,
      _buildItem(
        context: context,
        destination: AppNavDestination.mission,
        current: current,
        assetName: "Mission_Icon.svg",
        builder: () => const MissionScreen(),
      ),
    ),
    MapEntry(
      AppNavDestination.home,
      _buildItem(
        context: context,
        destination: AppNavDestination.home,
        current: current,
        assetName: "Home_Icon.svg",
        builder: () => const HomeScreen(),
      ),
    ),
    MapEntry(
      AppNavDestination.user,
      _buildItem(
        context: context,
        destination: AppNavDestination.user,
        current: current,
        assetName: "User_Icon.svg",
        builder: () => const StatusScreen(),
      ),
    ),
    MapEntry(
      AppNavDestination.setting,
      _buildItem(
        context: context,
        destination: AppNavDestination.setting,
        current: current,
        assetName: "Setting_Icon.svg",
        builder: () => const SettingScreen(),
      ),
    ),
  ];

  return entries.map((entry) {
    final overrideBuilder = overrides?[entry.key];
    if (overrideBuilder != null) {
      return overrideBuilder(entry.value);
    }
    return entry.value;
  }).toList();
}

typedef _ScreenBuilder = Widget Function();

BottomNavItem _buildItem({
  required BuildContext context,
  required AppNavDestination destination,
  required AppNavDestination current,
  required String assetName,
  required _ScreenBuilder builder,
}) {
  return BottomNavItem(
    assetName: assetName,
    isActive: destination == current,
    onTap: destination == current
        ? null
        : () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => builder(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                  );

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
              ),
            );
          },
  );
}
