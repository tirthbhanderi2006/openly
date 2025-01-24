import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:mithc_koko_chat_app/pages/features/search_page.dart';
import 'package:mithc_koko_chat_app/services/auth_services/auth_services.dart';
import 'package:mithc_koko_chat_app/pages/settings/setting_page.dart';
import 'package:provider/provider.dart'; // Ensure Provider is used for ThemeProvider
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header with logo
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/assets/telegram.png',width: 90,),
                  const SizedBox(height: 10),
                  Text(
                    "OPENLY",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // profile option
          _buildDrawerItem(
            context,
            icon: FlutterRemix.user_3_line,
            label: 'P R O F I L E',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(context, SlideRightPageTransition(child: ProfilePage(userId: FirebaseAuth.instance.currentUser!.uid)));
            },
            isDark: isDark,
          ),

          // Home option
          _buildDrawerItem(
            context,
            icon: FlutterRemix.home_smile_line,
            label: 'H O M E',
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
            isDark: isDark,
          ),

          // Settings option
          _buildDrawerItem(
            context,
            icon: FlutterRemix.search_eye_line,
            label: 'S E A R C H',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                  context,
                  SlideRightPageTransition(child: SearchPage())
              );
            },
            isDark: isDark,
          ),

          // Settings option
          _buildDrawerItem(
            context,
            icon: FlutterRemix.settings_5_line,
            label: 'S E T T I N G S',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                  SlideRightPageTransition(child: SettingPage())
              );
            },
            isDark: isDark,
          ),

          const Spacer(),

          // Logout option
          _buildDrawerItem(
            context,
            icon: FlutterRemix.logout_circle_r_line,
            label: 'Logout',
            onTap: () {
              Navigator.pop(context); // Close drawer
              _logout(context);
            },
            isDark: isDark,
            isLogout: true,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required void Function()? onTap,
        required bool isDark,
        bool isLogout = false,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? colorScheme.error
            : colorScheme.inversePrimary, // Adapt icon color
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isLogout
              ? colorScheme.error
              : colorScheme.inversePrimary, // Match icon color for consistency
        ),
      ),
      onTap: onTap,
    );
  }



  void _logout(BuildContext context) {
    // Logout logic with a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              AuthService().signOut(context); // Perform sign-out
            },
            child: const Text('Logout',style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }
}
