import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_left_page_transition.dart';

import '../../components/widgets_components/user_tile.dart';
import '../../services/chat_services/chat_services.dart';
import 'chat_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    ChatServices().getFollowingList(FirebaseAuth.instance.currentUser!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: AppBar(
      //   title: const Text(
      //     "C H A T",
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Theme.of(context).colorScheme.primary,
      // ),
      body: _buildUsersList(),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatServices().getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show skeleton loader while waiting for data
          return _buildSkeletonLoader();
        }

        // Check if snapshot has data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return emptyUserAnimation(context);
        }

        // Apply delay before showing actual data
        return FutureBuilder(
          future: Future.delayed(
              const Duration(milliseconds: 1000), () => snapshot.data!),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              // Show skeleton loader during delay
              return _buildSkeletonLoader();
            }

            // Build the user list after the delay
            return ListView(
              children: futureSnapshot.data!
                  .map((userData) => _buildUsersListItem(userData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      userId: userData['uid'],
      text: userData['email'],
      imgUrl: userData['profilePic'],
      onTap: () {
        Navigator.push(
          context,
          SlideLeftPageTransition(
            child: ChatPage(
              receiverEmail: userData['email'],
              receiverId: userData['uid'],
            ),
          ),
        );
      },
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
              child: UserTile(
                  text: "users email id",
                  onTap: () {},
                  userId: "userId",
                  imgUrl: "https://www.gravatar.com/avatar/?d=identicon")),
        );
      },
    );
  }

  // no user found widget
  Widget emptyUserAnimation(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 250,
                width: 250,
                child: Lottie.asset(
                  'lib/assets/no-user-found.json',
                  fit: BoxFit
                      .contain, // Makes sure the animation scales to fill the space
                ),
              ),
              Text(
                'No users found',
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
