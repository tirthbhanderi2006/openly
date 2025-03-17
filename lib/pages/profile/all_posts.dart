import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/pages/features/create_post_page.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

import '../../components/features_components/post_tile.dart';
import '../../components/widgets_components/create_post_button.dart';

class AllPosts extends StatelessWidget {
  final String userId;

  const AllPosts({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'P O S T S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        // Remove shadow for a cleaner look
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildAllPosts(),
    );
  }

  Widget _buildAllPosts() {
    return StreamBuilder<List<PostModel>>(
      stream: PostServices().getPostsByUser(userId: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'lib/assets/no-post.json', // Add an error animation
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong!',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Handle empty bookmarks
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'lib/assets/no-post.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Post yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                //create  post button
                CreatePostButton(),
              ],
            ),
          );
        }

        final posts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: posts.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: 16), // Add spacing between items
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
