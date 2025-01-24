import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class UserGrid extends StatelessWidget {
  final String userId;
  final String userName;
  final String userImage;

  const UserGrid({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0), // Add spacing between grid tiles
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              SlideUpNavigationAnimation(child: ProfilePage(userId: userId)));
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Profile Image with Shadow
                Stack(
                  children: [
                    // Shadow Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          userImage,
                          fit: BoxFit.cover,
                          height: 80,
                          width: 80,
                        ),
                      ),
                    ),
                    // Online Indicator (Optional)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                          color: Colors.green, // Online indicator color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 10), // Add spacing between image and text
                // Username
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long usernames
                  maxLines: 1,
                ),
                const SizedBox(
                    height: 10), // Add spacing between text and button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
