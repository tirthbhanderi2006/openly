import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:mithc_koko_chat_app/pages/chat/create_group.dart';
import 'package:mithc_koko_chat_app/pages/chat/group_chat_screen.dart';
import 'package:mithc_koko_chat_app/services/chat_services/group_chat_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_right_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class ShowGroup extends StatelessWidget {
  const ShowGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      // appBar: AppBar(
      //   title: const Text(
      //     "G R O U P S",
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: Theme.of(context).colorScheme.primary,
      //   elevation: 0,
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream: GroupChatServises().fetchUserGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FlutterRemix.group_2_line,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No groups yet!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          var groups = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index].data() as Map<String, dynamic>;
              String groupId = groups[index].id;
              String groupName = group['name'];
              String groupImage = group['image'] ?? '';
              String lastMessage = group['lastMessage'] ?? 'No messages yet';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRightPageTransition(
                        child: GroupChatScreen(
                          groupId: groupId,
                          groupName: groupName,
                          members: List<String>.from(group['members']),
                          createdBy: group['createdBy'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        // Group Image
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: groupImage.isNotEmpty
                              ? NetworkImage(groupImage)
                              : null,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: groupImage.isEmpty
                              ? Icon(
                                  FlutterRemix.group_2_line,
                                  size: 30,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),

                        // Group Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group Name
                              Text(
                                groupName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Last Message
                              Text(
                                "${groups[index]['members'].length.toString()} members",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondary
                              .withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              SlideUpNavigationAnimation(child: CreateGroupScreen()),
            );
          },
          child: Icon(FlutterRemix.group_2_line),
        ),
      ),
    );
  }
}
