import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageWithPreview extends StatelessWidget {
  final String profilePicUrl;

  const ProfileImageWithPreview({super.key, required this.profilePicUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          barrierDismissible:
              true, // Allow dismissal by tapping outside the dialog
          builder: (BuildContext context) {
            return Center(
              // Center the dialog explicitly
              child: Material(
                color:
                    Colors.transparent, // Transparent material for the dialog
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
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
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
    );
  }
}
