import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:mithc_koko_chat_app/controllers/navigation_controller.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    final isDarkMode = ThemeProvider().isDarkMode;
    

    final selectedColor = isDarkMode ? Colors.white : Colors.black;
    final unselectedColor = isDarkMode ? Colors.white60 : Colors.black54;
    final backgroundColor = isDarkMode
        ? Colors.grey[900]!.withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Obx(() {
                  final currentIndex = navigationController.currentIndex.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      ),
                      _buildNavItem(
                        icon: Icons.add_circle_outline_rounded,
                        selectedIcon: Icons.add_circle_rounded,
                        label: 'Post',
                        index: 2,
                        currentIndex: currentIndex,
                        onTap: () => navigationController.changeIndex(2),
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
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
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.10 : 0.90,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.7,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
