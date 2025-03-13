import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/controllers/group_chat_controller.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final GroupChatController groupChatController =
      Get.put(GroupChatController());

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeProvider().isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Create Group",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "Group Name",
                prefixIcon: const Icon(Icons.group),
                filled: true,
                fillColor: isDark
                    ? Colors.grey[900]
                    : Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),

            // User Selection List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _buildUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No users found!",
                        style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    );
                  }

                  var users = snapshot.data!;
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, index) => Divider(
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                    ),
                    itemBuilder: (context, index) {
                      var user = users[index];
                      String userId = user['uid'];
                      String username = user['name'];
                      String email = user['email'];
                      String profilePic = user['profilePic'] ??
                          "https://via.placeholder.com/150";

                      return Obx(
                        () => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          leading: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(profilePic),
                            radius: 28,
                          ),
                          title: Text(
                            username,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black),
                          ),
                          subtitle: Text(
                            email,
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),
                          trailing: Checkbox(
                            value: groupChatController.selectedUsers
                                .contains(userId),
                            onChanged: (bool? value) {
                              groupChatController.toggleUserSelection(userId);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Create Group Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      groupChatController.isLoading.value ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: isDark
                        ? Colors.white
                        : Colors.black, // Fix applied here
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: groupChatController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Create Group"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty ||
        groupChatController.selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a group name and select users.")),
      );
      return;
    }

    groupChatController.isLoading.value = true;

    String groupId =
        FirebaseFirestore.instance.collection('groupChats').doc().id;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Add creator to the group members list
    groupChatController.selectedUsers.add(currentUserId);

    await FirebaseFirestore.instance.collection('groupChats').doc(groupId).set({
      'name': _groupNameController.text.trim(),
      'createdBy': currentUserId,
      'members': groupChatController.selectedUsers,
      'createdAt': FieldValue.serverTimestamp(),
      'image':
          'https://imgs.search.brave.com/Hcmzrb57J7ck-0du50YeYYh_-xFH2xjERQZE43QHOSU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzFmLzIw/L2YzLzFmMjBmMzVm/ZTcyMmVlNzFlYTEx/ZjdkNzQ1MDBhODhm/LmpwZw'
    });
    groupChatController.selectedUsers.clear();

    groupChatController.isLoading.value = false;
    Navigator.pop(context);
  }

  Stream<List<Map<String, dynamic>>> _buildUsers() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    final blockedUsersStream = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .collection("BlockedUsers")
        .snapshots();

    return blockedUsersStream.asyncMap((blockedSnapshot) async {
      final blockUserIds = blockedSnapshot.docs.map((doc) => doc.id).toList();
      final followingList =
          await ChatServices().getFollowingList(currentUser.uid);

      final usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();
      return usersSnapshot.docs
          .where((doc) =>
              doc.id != currentUser.uid &&
              !blockUserIds.contains(doc.id) &&
              followingList.contains(doc.id))
          .map((doc) => {
                'uid': doc.id,
                'name': doc.data()['name'],
                'email': doc.data()['email'],
                'profilePic': doc.data()['profilePic'] ??
                    "https://via.placeholder.com/150",
              })
          .toList();
    });
  }
}
