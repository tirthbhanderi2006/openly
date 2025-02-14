import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/features_components/post_tile.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';

class ShowBookmarks extends StatelessWidget {
  const ShowBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'B O O K M A R K S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0, // Remove shadow for a cleaner look
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildBookmarksList(),
    );
  }

  Widget _buildBookmarksList() {
    return StreamBuilder<List<PostModel>>(
      stream: PostServices().getBookmarksStream(),
      builder: (context, snapshot) {
        // Handle different connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'lib/assets/empty-list.json', // Add an error animation
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
                  'lib/assets/empty-list.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No bookmarks yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start bookmarking posts to see them here.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Display bookmarks
        final bookmarks = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: 16), // Add spacing between items
          itemBuilder: (context, index) {
            final post = bookmarks[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
