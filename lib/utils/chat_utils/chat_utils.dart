import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class ChatUtils {
  //showing profile picture

  static showProfilePicture(
      {required String profilePicUrl, required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return Center(
          // Center the dialog explicitly
          child: Material(
            color: Colors.transparent, // Transparent material for the dialog
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Blurred Background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                // Circular Profile Image
                Container(
                  height: 220, // Profile image size
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        profilePicUrl.isNotEmpty
                            ? profilePicUrl
                            : 'https://www.gravatar.com/avatar/?d=identicon',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showProfileDialog(
      BuildContext context, String? profilePicUrl, String receiverId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Profile Options',
            style: TextStyle(),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      SlideUpNavigationAnimation(
                        child: ProfilePage(userId: receiverId),
                      ),
                    );
                  },
                  child: Text(
                    'Visit Profile',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ChatUtils.showProfilePicture(
                        profilePicUrl: profilePicUrl!, context: context);
                  },
                  child: Text(
                    'View Profile Picture',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget emptyChatWidget(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'lib/assets/empty_chat.json',
                height: 180,
              ),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color, // Adapts text color
                ),
              ),
              // Removed the SizedBox with height 8
              Text(
                'Start a conversation with your friends',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color, // Adjusts for theme
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
