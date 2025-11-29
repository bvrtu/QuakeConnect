import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.map, 'Map', 1),
          _buildNavItem(Icons.shield, 'Safety', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
          _buildNavItem(Icons.settings, 'Settings', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkResponse(
        radius: 28,
        onTap: () => onTap(index),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: isSelected ? 1.0 : 0.95, end: isSelected ? 1.0 : 0.95),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(begin: Colors.grey, end: isSelected ? Colors.red : Colors.grey),
                duration: const Duration(milliseconds: 220),
                builder: (context, color, _) => Icon(icon, color: color, size: 24),
              ),
            const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.red : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
                child: Text(label),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
