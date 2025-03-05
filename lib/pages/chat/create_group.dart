import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/controllers/group_chat_controller.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "Create Group",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "Group Name",
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Selection List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _buildUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.data!.isEmpty){
                    return const Center(child: Text("No users found!"),);
                  }

                  var users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      String userId = user['uid'];
                      String username = user['name'];
                      String email = user['email'];
                      String profilePic = user['profilePic'] ??
                          "https://via.placeholder.com/150"; // Default avatar

                      return Obx(
                        () => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(profilePic),
                            radius: 25,
                          ),
                          title: Text(username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text(email, style: const TextStyle(fontSize: 12)),
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

            // Create Group Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      groupChatController.isLoading.value ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: groupChatController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
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
