import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';

import '../../utils/page_transition/slide_up_page_transition.dart';
import '../../services/features_services/post_services.dart';

class ProfileWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String postId;
  final String postedOn;
  const ProfileWidget({
    required this.userId,
    required this.userName,
    required this.postId,
    required this.postedOn,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late Future<String> _userImageFuture;

  @override
  void initState() {
    super.initState();
    _userImageFuture = getCurrentUserImage(widget.userId);
  }

  Future<String> getCurrentUserImage(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        return userDetails["profilePic"] ?? '';
      } else {
        return 'No user found';
      }
    } catch (e) {
      return 'Error fetching profile picture';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<String>(
          future: _userImageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                radius: 20,
                child: const CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == 'No user found') {
              return CircleAvatar(
                backgroundColor: Theme.of(context).dividerColor,
                radius: 20,
                child: Icon(Icons.person,
                    color: Theme.of(context).iconTheme.color),
              );
            }

            return CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(snapshot.data!),
              radius: 20,
            );
          },
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            SlideUpNavigationAnimation(
                child: ProfilePage(userId: widget.userId)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              Text(
                widget.postedOn,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10),
              )
            ],
          ),
        ),
        const Spacer(),
        // Delete/Block Options
        widget.userId == FirebaseAuth.instance.currentUser!.uid
            ? IconButton(
                icon: Icon(
                  FlutterRemix.delete_bin_line,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete!'),
                        content: const Text(
                            'Are you sure you want to delete this post?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              PostServices().deletePost(postId: widget.postId);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ):
              SizedBox.shrink(), 
              // block option
            // : PopupMenuButton<String>(
            //     icon: Icon(
            //       Icons.more_vert,
            //       color: Theme.of(context).colorScheme.primary,
            //     ),
            //     onSelected: (value) {
            //       if (value == 'block') {
            //         ChatServices().blockUser(widget.userId);
            //       }
            //     },
            //     itemBuilder: (context) => [
            //       PopupMenuItem<String>(
            //         value: 'block',
            //         child: Row(
            //           children: [
            //             Icon(Icons.block,
            //                 color: Theme.of(context).colorScheme.error),
            //             const SizedBox(width: 10),
            //             const Text('Block User'),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
      ],
    );
  }
}
