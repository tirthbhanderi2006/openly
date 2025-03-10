import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class PostsGridView extends StatelessWidget {
  final List<PostModel> posts;
  final String userId;

  const PostsGridView({
    Key? key,
    required this.posts,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          "No posts available",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemCount: posts.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            // Using a more direct approach with GestureDetector
            showPostPreview(context, index, posts);
          },
          onLongPressEnd: (_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          onTap: () {
            Navigator.push(
              context,
              SlideUpNavigationAnimation(
                child: FullScreenImage(
                  imageUrl: posts[index].imgUrl,
                  caption: posts[index].caption,
                ),
              ),
            );
          },
          child: Hero(
            tag: 'post_preview_${posts[index].postId}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: posts[index].imgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child:
                      Icon(Icons.image_not_supported, color: Colors.grey[500]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showPostPreview(BuildContext context, int index, List<PostModel> posts) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isPostOwner =
        currentUser != null && currentUser.uid == posts[index].userId;

    showDialog(
      context: context,
      barrierDismissible: false,
      // Using a custom dialog for better appearance
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => true, // Prevent back button from closing
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Close button at the top-right corner

                    // Post image with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Hero(
                        tag: 'post_preview_${posts[index].postId}',
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: posts[index].imgUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Caption with fade in animation
                    if (posts[index].caption != null &&
                        posts[index].caption!.isNotEmpty)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 450),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value, // Fade-in effect
                            child: Transform.translate(
                              offset: Offset(0,
                                  10 * (1 - value)), // Smooth slide-up effect
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            posts[index].caption ?? " ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Ensures vertical alignment
                      children: [
                        // Close button
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 450),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0,
                                  10 *
                                      (1 - value)), // Smooth slide-up animation
                              child: Opacity(
                                opacity: value, // Fade-in effect
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 50, // Ensures consistent height
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 30),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 16), // Space between buttons

                        // Delete option (only shown to post owner)
                        if (isPostOwner)
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 450),
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0,
                                    10 *
                                        (1 -
                                            value)), // Smooth slide-up transition
                                child: Opacity(
                                  opacity: value, // Fade-in effect
                                  child: child,
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 50, // Matches the close button height
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showDeleteConfirmation(
                                        context, posts[index]);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.delete, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete Post',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Delete Post',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              PostServices().deletePost(postId: post.postId);
              Navigator.of(context).pop();
              // Show a confirmation snackbar
              Get.snackbar("Post", "Post Deleted !",
                  colorText: Colors.white, backgroundColor: Colors.green);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
