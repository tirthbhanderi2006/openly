import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/components/features_components/post_header_widget.dart';
import 'package:mithc_koko_chat_app/controllers/post_controller.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  PostCard({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final PostController controller =
        Get.put(PostController(post), tag: post.postId);

    // Retrieve the current theme's colors
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.background.withOpacity(0.8),
            colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        color: Colors.transparent, // Make the card transparent
        elevation: 0, // Remove elevation since the container has a shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header (Profile Info)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ProfileWidget(
                userId: post.userId,
                userName: post.userName,
                postId: post.postId,
                postedOn: post.timeStamp.toLocal().toString().split(' ')[0],
              ),
            ),

            // Post Image with Gradient Overlay
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      SlideRightPageTransition(
                          child: FullScreenImage(
                        imageUrl: post.imgUrl,
                        caption: post.caption,
                      ))),
                  onDoubleTap: () => controller.toggleLike(
                    postId: post.postId,
                    userId: FirebaseAuth.instance.currentUser!.uid,
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    child: GestureDetector(
                      onDoubleTap: () => controller.toggleLike(
                        postId: post.postId,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.imgUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 450,
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              color: colorScheme.secondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Interaction Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  // Like Button with Animation
                  Obx(() => AnimatedScale(
                        scale: controller.isLiked.value ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: Icon(
                            controller.isLiked.value
                                ? FlutterRemix.heart_3_fill
                                : FlutterRemix.heart_3_line,
                            color: controller.isLiked.value
                                ? Colors.red
                                : colorScheme.onSurface,
                          ),
                          onPressed: () => controller.toggleLike(
                            postId: post.postId,
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      )),
                  // Comment Button
                  IconButton(
                    icon: Icon(
                      FlutterRemix.chat_3_line,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      controller.openCommentSheet(context);
                    },
                  ),
                  // Share Button
                  IconButton(
                    icon: Obx(() {
                      // Dynamically update the button based on state
                      if (controller.isDownloading.value) {
                        return SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onSurface,
                            strokeWidth: 2,
                          ),
                        );
                      } else if (controller.isDownloadComplete.value) {
                        return Icon(Icons.check, color: Colors.green);
                      } else {
                        return Icon(FlutterRemix.download_line,
                            color: colorScheme.onSurface);
                      }
                    }),
                    onPressed: () {
                      if (!controller.isDownloading.value) {
                        controller.downloadImage(
                            imgurl: post.imgUrl, context: context);
                      }
                    },
                  ),

                  const Spacer(),
                  // Bookmark Button
                  Obx(() => IconButton(
                        icon: Icon(
                          controller.isBookmarked.value
                              ? FlutterRemix.bookmark_3_fill
                              : FlutterRemix.bookmark_3_line,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () => !controller.isBookmarked.value
                            ? controller.addBookmark(model: post,context:context)
                            : controller.removeBookmark(postId: post.postId,context:context),
                      )),
                ],
              ),
            ),

            // Post Caption with Better Typography
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.058, // Fixed max height
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.5, // Improved line height
                      ),
                      children: [
                        TextSpan(
                          text: post.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            color: colorScheme.primary, // Highlight username
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: post.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Add a subtle divider
            Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.onSurface.withOpacity(0.1),
              indent: 12,
              endIndent: 12,
            ),

            // Like and Comment Count
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    FlutterRemix.heart_3_fill,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likes.length} likes',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    FlutterRemix.chat_3_fill,
                    color: colorScheme.onSurface.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments.length} comments',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
