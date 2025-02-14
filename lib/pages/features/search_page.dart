import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/features_components/search_user_tile.dart';
import 'package:mithc_koko_chat_app/controllers/search_controller.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatelessWidget {
  final SearchPageController controller = Get.put(SearchPageController());

  @override
  Widget build(BuildContext context) {
    controller.searchResults.clear();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "S E A R C H",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildSearchResults(context),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search by email...",
          prefixIcon: const Icon(FlutterRemix.user_search_line),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.trim().isNotEmpty) {
            controller.hasSearched.value = true; // Mark as searched
            controller.fetchUsers(value);
          }
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            controller.hasSearched.value = true; // Mark as searched
            controller.fetchUsers(value);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingSkeleton();
      }

      if (!controller.hasSearched.value) {
        // Show "Search here" message before searching
        return _buildInitialSearchMessage(context);
      }

      if (controller.searchResults.isEmpty) {
        // Show "No results found" after searching
        return _buildNoResultsFound(context);
      }

      // Show actual search results
      return Expanded(
        child: ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final user = controller.searchResults[index];
            return SearchUserTile(
              userName: user['name'] ?? 'Unknown',
              userId: user['userId'] ?? '',
              imgUrl: user['profilePic'],
              email: user['email'] ?? '',
              onTap: () => Navigator.push(
                context,
                SlideUpNavigationAnimation(
                  child: ProfilePage(userId: user['uid']),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return Expanded(
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Skeletonizer(
              enabled: true,
              child: SearchUserTile(
                userName: "userName",
                userId: "userId",
                imgUrl: "https://www.gravatar.com/avatar/?d=identicon",
                email: "email",
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialSearchMessage(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('lib/assets/search-animation.json',
                width: 300, height: 250),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text(
                "Search for users and connect instantly!",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsFound(BuildContext context) {
    controller.hasSearched.value = false;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('lib/assets/no-data-found.json',
                width: 300, height: 250),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Text(
                "Hmm... couldn't find anyone. Try another search!",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
