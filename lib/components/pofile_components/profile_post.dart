import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class PostsGridView extends StatelessWidget {
  final List<PostModel> posts;
  final String userId;
  // final Function(BuildContext context, int index, List<PostModel> posts) onLongPress;

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
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(context, SlideUpNavigationAnimation(child: FullScreenImage(imageUrl: posts[index].imgUrl,caption: posts[index].caption,))),
          onLongPress: () => _showPostPreviewDialog(context, index, posts),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl:posts[index].imgUrl,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _showPostPreviewDialog(
      BuildContext context, int index, List<PostModel> posts) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:posts[index].imgUrl,
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        posts[index].caption ?? "No caption available.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (userId == FirebaseAuth.instance.currentUser!.uid)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                PostServices()
                                    .deletePost(postId: posts[index].postId);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// old code

// Expanded(
//             child: Obx(() {
//               final posts = profileController.posts;
//               if (posts.isEmpty) {
//                 return Center(
//                   child: Text(
//                     "No posts available",
//                     style:
//                         TextStyle(color: Theme.of(context).colorScheme.primary),
//                   ),
//                 );
//               }
//               return GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 5.0,
//                   mainAxisSpacing: 5.0,
//                 ),
//                 itemCount: posts.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onLongPress: () =>
//                         _showPostPreviewDialog(context, index, posts),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(5),
//                       child: Image.network(
//                         posts[index].imgUrl,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
