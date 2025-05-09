import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/user_tile.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../components/features_components/search_user_tile.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "B L O C K E D  U S E R S",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBlockedUsersList(context),
    );
  }

  Widget _buildBlockedUsersList(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatServices()
          .getBlockedUsersStream(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonLoader(); // Show skeleton loader while waiting
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final blockedUsers = snapshot.data ?? [];
        if (blockedUsers.isEmpty) {
          // return const Center(child: Text('No Blocked users found'));
          return emptyChatWidget(context);
        }

        return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return UserTile(
                  text: user['email'],
                  onTap: () =>
                      _showUnblockDialog(context: context, userId: user['uid']),
                  userId: user['uid'],
                  imgUrl: user['profilePic'],
                );
              },
            );
      },
    );
  }

  void _showUnblockDialog(
      {required BuildContext context, required String userId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock user'),
        content: const Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatServices().unblockUser(userId);
              Navigator.pop(context);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('User Unblocked!')),
              // );
              Get.snackbar("Unblock", "User Unblocked!",
                  backgroundColor: Colors.green,
                  colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text(
              'Unblock user',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 6, // Number of skeleton items to show
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Skeletonizer(
              enabled: true,
              child: SearchUserTile(
                  userName: "userName",
                  userId: "userId",
                  imgUrl: "https://www.gravatar.com/avatar/?d=identicon",
                  email: "email",
                  onTap: () {})),
        );
      },
    );
  }

  // no user found widget
  Widget emptyChatWidget(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'lib/assets/no-block-user.json',
                height: 180,
              ),
              Text(
                'No Blocked users found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color, // Adapts text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
