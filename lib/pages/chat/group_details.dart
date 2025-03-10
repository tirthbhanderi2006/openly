import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:mithc_koko_chat_app/components/profile_components/profile_picture.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/user_tile.dart';
import 'package:mithc_koko_chat_app/main.dart';
import 'package:mithc_koko_chat_app/pages/chat/edit_group.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services/group_chat_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final String adminId;
  final List<dynamic> members;

  GroupDetails({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.adminId,
    required this.members,
  });

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> with RouteAware {
  late Future<Map<String, dynamic>> _groupDetailsFuture;

  @override
  void initState() {
    super.initState();
    _groupDetailsFuture = _fetchGroupDetails();
  }

  @override
  void didChangeDependencies() {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    setState(() {
      _groupDetailsFuture = _fetchGroupDetails();
    });
    super.didPopNext();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchGroupDetails() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        return groupSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Group not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch group details: $e")),
      );
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        centerTitle: true,
        actions: [
          widget.adminId == FirebaseAuth.instance.currentUser!.uid
              ? IconButton(
                  icon: const Icon(FlutterRemix.edit_2_line),
                  onPressed: () {
                    Navigator.push(
                        context,
                        SlideUpNavigationAnimation(
                            child: EditGroupPage(
                                groupId: widget.groupId,
                                groupName: widget.groupName,
                                groupImage: widget.groupImage,
                                adminId: widget.adminId,
                                members: widget.members)));
                  })
              : const SizedBox.shrink(),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            onPressed: () {
              GroupChatServises().leaveGroup(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  groupId: widget.groupId);
            },
            tooltip: 'Leave Group',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _groupDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No group details found.'));
          }

          final groupData = snapshot.data!;
          final groupImage = groupData['image'] ?? widget.groupImage;
          final groupName = groupData['name'] ?? widget.groupName;
          final members = List.from(groupData['members'] ?? widget.members);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileImageWithPreview(
                  profilePicUrl: groupImage,
                ),
                // Group Image
                // CircleAvatar(
                //   radius: 60,
                //   backgroundImage:
                //       groupImage.isNotEmpty ? NetworkImage(groupImage) : null,
                //   backgroundColor: Colors.grey[300],
                //   child: groupImage.isEmpty
                //       ? const Icon(Icons.group, size: 60, color: Colors.white)
                //       : null,
                // ),
                const SizedBox(height: 20),

                // Group Name
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Admin Details
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Admin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder<Map<String, String>>(
                  future: getUserDetails(widget.adminId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        title: Text("Loading admin..."),
                        leading: CircleAvatar(
                            child: Icon(Icons.admin_panel_settings)),
                      );
                    }
                    final adminData = snapshot.data!;
                    return UserTile(
                      text: adminData['name'].toString(),
                      onTap: () {
                        Navigator.push(
                            context,
                            SlideUpNavigationAnimation(
                                child: ProfilePage(userId: widget.adminId)));
                      },
                      userId: widget.adminId,
                      imgUrl: adminData['profilePic'],
                    );
                  },
                ),

                const Divider(),

                // Members List
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    // Check if the current member is the admin
                    if (members[index] == widget.adminId) {
                      return const SizedBox.shrink(); // Skip the admin user
                    }
                    return FutureBuilder<Map<String, String>>(
                      future: getUserDetails(members[index]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ListTile(
                            title: Text("Loading..."),
                            leading: CircleAvatar(child: Icon(Icons.person)),
                          );
                        }
                        final userData = snapshot.data!;
                        return UserTile(
                          text: userData['name'].toString(),
                          onTap: () {
                            Navigator.push(
                                context,
                                SlideUpNavigationAnimation(
                                    child:
                                        ProfilePage(userId: members[index])));
                          },
                          userId: members[index],
                          imgUrl: userData['profilePic'],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, String>> getUserDetails(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        return {
          "name": userDetails["name"] ?? "Unknown User",
          "profilePic": userDetails["profilePic"] ?? "",
        };
      } else {
        return {"name": "Unknown User", "profilePic": ""};
      }
    } catch (e) {
      return {"name": "Error fetching user", "profilePic": ""};
    }
  }
}
