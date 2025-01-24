import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/features_components/search_user_tile.dart';
import 'package:mithc_koko_chat_app/controllers/search_controller.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPage extends StatelessWidget {
  final SearchPageController controller = Get.put(SearchPageController());

  @override
  Widget build(BuildContext context) {
    controller.searchResults.value.clear();
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
          Obx(() => controller.isLoading.value
              ? _buildSearchResults(context)
              : _buildSearchResults(context)),
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
        onSubmitted: (value) => controller.fetchUsers(value),
      ),
    );
  }

  Widget _buildSearchResults(context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Skeletonizer(
                  enabled: true,
                  child: SearchUserTile(userName: "userName", userId: "userId", imgUrl: "https://www.gravatar.com/avatar/?d=identicon", email: "email", onTap: (){}),
                ),
              );
            },
          ),
        );
      }
      if (controller.searchResults.isEmpty) {
        // Show a message when no results are found
        return Expanded(
          child: Center(
            child: Text(
              "No results found.",
              style:
              TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
        );
      }
      // Show actual search results
      return Expanded(
        child:
        ListView.builder(
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


  Widget _buildLoadingIndicator() {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
