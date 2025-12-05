import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavItem {
  final String assetName;
  final VoidCallback? onTap;
  final bool isActive;

  const BottomNavItem({
    required this.assetName,
    this.onTap,
    this.isActive = false,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.items,
  }) : assert(items.length == 5, 'Bottom nav currently expects five icons.');

  @override
  Widget build(BuildContext context) {
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
        children: items
            .map((item) => _NavIcon(
                  assetName: item.assetName,
                  onTap: item.onTap,
                  isActive: item.isActive,
                ))
            .toList(),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String assetName;
  final VoidCallback? onTap;
  final bool isActive;

  const _NavIcon({
    required this.assetName,
    this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildIcon(),
    );
  }

  Widget _buildIcon() {
    final path = "assets/icons/$assetName";
    final Color iconColor = isActive ? const Color(0xFF3C86C0) : Colors.black;

    if (assetName.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: 19,
        height: 19,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    }

    return Image.asset(
      path,
      width: 19,
      height: 19,
      color: iconColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
