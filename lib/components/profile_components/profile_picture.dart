import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePicture extends StatelessWidget {
  final String profilePicUrl;

  const ProfilePicture({super.key, required this.profilePicUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Get.dialog(
          ProfileDialog(profilePicUrl: profilePicUrl),
          barrierDismissible: true, // Tap outside to close
        );
      },
      child: Container(
        height: 160,
        width: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profilePicUrl.isNotEmpty
                ? profilePicUrl
                : 'https://www.gravatar.com/avatar/?d=identicon',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 70,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileDialog extends StatefulWidget {
  final String profilePicUrl;

  const ProfileDialog({super.key, required this.profilePicUrl});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.reverse();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
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
              // Animated Circular Profile Image
              Container(
                height: 220,
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
                      widget.profilePicUrl.isNotEmpty
                          ? widget.profilePicUrl
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
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    _animationController.reverse().then((_) {
                      Get.back();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
