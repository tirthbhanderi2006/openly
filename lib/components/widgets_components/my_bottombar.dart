import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mithc_koko_chat_app/controllers/navigation_controller.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class MyBottomBar extends StatelessWidget {
  const MyBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    final isDarkMode = ThemeProvider().isDarkMode;

    // Dynamic theme-based colors
    final selectedColor = isDarkMode ? Colors.white : Colors.black;
    final unselectedColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final backgroundColor = isDarkMode
        ? Colors.black.withOpacity(0.85)
        : Colors.white.withOpacity(0.90);
    final glowColor = isDarkMode
        ? Colors.grey.shade800.withOpacity(0.3)
        : Colors.grey.shade300.withOpacity(0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade300.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
                child: Obx(() {
                  final currentIndex = navigationController.currentIndex.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: FlutterRemix.home_smile_2_line,
                        selectedIcon: FlutterRemix.home_smile_2_fill,
                        label: 'Home',
                        index: 0,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(0),
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        glowColor: glowColor,
                      ),
                      _buildNavItem(
                        icon: FlutterRemix.search_eye_line,
                        selectedIcon: FlutterRemix.search_eye_fill,
                        label: 'Search',
                        index: 1,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(1),
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        glowColor: glowColor,
                      ),
                      _buildCenterButton(
                        icon: Icons.add_rounded,
                        index: 2,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(2),
                      ),
                      _buildNavItem(
                        icon: FlutterRemix.user_heart_line,
                        selectedIcon: FlutterRemix.user_heart_fill,
                        label: 'Profile',
                        index: 3,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(3),
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        glowColor: glowColor,
                      ),
                      _buildNavItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        selectedIcon: Icons.chat_bubble_rounded,
                        label: 'Chat',
                        index: 4,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(4),
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        glowColor: glowColor,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    required Color selectedColor,
    required Color unselectedColor,
    required Color glowColor,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCirc,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? glowColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: isSelected
                  ? Matrix4.translationValues(0, -4, 0)
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              child: AnimatedScale(
                scale: isSelected ? 1.15 : 0.85,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: isSelected ? 12.0 : 11.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required IconData icon,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade800 : Colors.grey.shade600,
            borderRadius:
                BorderRadius.circular(20), 
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
                blurRadius: isSelected ? 12 : 5,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: AnimatedScale(
            scale: isSelected ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
