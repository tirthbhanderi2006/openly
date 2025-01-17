import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/search_user_tile.dart';
import 'package:mithc_koko_chat_app/controllers/search_controller.dart';
import 'package:mithc_koko_chat_app/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/pages/profile_page.dart';

class SearchPage extends StatelessWidget {
  final SearchPageController controller = Get.put(SearchPageController());

  @override
  Widget build(BuildContext context) {
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
              ? _buildLoadingIndicator()
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
          prefixIcon: const Icon(Icons.search),
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
      if (controller.searchResults.isEmpty) {
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

  Widget _buildLoadingIndicator() {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
