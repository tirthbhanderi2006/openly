import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/controllers/chat_background_controller.dart';
import 'package:mithc_koko_chat_app/controllers/fonts_controller.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'blocked_users_page.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});
  final FontController fontController = Get.put(FontController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ChatBackgroundController backgroundController =
        Get.put(ChatBackgroundController());

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allows the background to extend behind the app bar
      appBar: AppBar(
        title: Text(
          "S E T T I N G S",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          /// Background Animation
          Positioned.fill(
            child:
                Lottie.asset('lib/assets/settings-bg.json', fit: BoxFit.cover),
          ),

          /// Glassmorphism Blur Effect
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 5, sigmaY: 5), // More blur for a premium look
                child: Container(
                  color: Colors.black.withOpacity(
                      0.2), // Subtle dark overlay for better visibility
                ),
              ),
            ),
          ),

          /// Settings Options
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Dark Mode Toggle
                  _buildSettingsCard(
                    context,
                    title: "Dark Mode",
                    icon: Icons.dark_mode_rounded,
                    trailing: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        );
                      },
                    ),
                  ),

                  /// Blocked Users Button
                  _buildSettingsCard(
                    context,
                    title: "Blocked Users",
                    icon: Icons.block,
                    onTap: () => Navigator.push(
                      context,
                      SlideUpNavigationAnimation(child: BlockedUsersPage()),
                    ),
                  ),

                  /// Blocked Users Button
                  _buildSettingsCard(
                    context,
                    title: "Change chat backgroud",
                    icon: FlutterRemix.save_2_line,
                    onTap: () =>
                        backgroundController.pickAndSaveBackgroundImage(),
                  ),

                  _buildSettingsCard(
                    context,
                    title: "Change App Font",
                    icon: FlutterRemix.a_b,
                    onTap: () {
                      _showFontSelectionDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Settings Card Widget
  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.1), // Glass effect
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28), // Icon
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

// font selection dialog
  _showFontSelectionDialog(context) {
    Get.bottomSheet(
      GestureDetector(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF212121) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Font',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Get.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // Font list
              SizedBox(
                height: 280,
                child: Obx(() => fontController.filteredFonts.isEmpty
                    ? Center(
                        child: Text(
                          'No fonts found',
                          style: TextStyle(
                            color: Get.isDarkMode
                                ? Colors.white.withOpacity(0.6)
                                : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: fontController.filteredFonts.length,
                        itemBuilder: (context, index) {
                          final font = fontController.filteredFonts[index];
                          final isSelected =
                              fontController.selectedFont.value == font;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (Get.isDarkMode
                                      ? Colors.blue.withOpacity(0.15)
                                      : Colors.blue.withOpacity(0.08))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(
                                font,
                                style: GoogleFonts.getFont(
                                  font,
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? (Get.isDarkMode
                                          ? Colors.blue[200]
                                          : Colors.blue[700])
                                      : (Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Get.isDarkMode
                                            ? Colors.blue[700]
                                            : Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                fontController.updateFont(font: font);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
    );
  }

// Search bar widget
  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Get.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              onChanged: (value) => fontController.filterFonts(value),
              decoration: InputDecoration(
                hintText: "Search fonts",
                hintStyle: TextStyle(
                  color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
