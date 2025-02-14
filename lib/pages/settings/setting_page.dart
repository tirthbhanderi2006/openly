import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/controllers/chat_background_controller.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'blocked_users_page.dart';
import 'package:path_provider/path_provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

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
                      MaterialPageRoute(
                          builder: (context) => BlockedUsersPage()),
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
}
