import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/main.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;
  final String adminId;
  final List<dynamic> members;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
    required this.adminId,
    required this.members,
  });

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> with RouteAware {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation

  String? _newGroupImage;
  List<dynamic> _updatedMembers = [];
  bool _isLoading = false;
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.groupName;
    _updatedMembers = List.from(widget.members);
    _fetchGroupDetails(); // Fetch initial group details
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute); // Subscribe to RouteObserver
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe from RouteObserver
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route is popped and this page becomes visible again
    _fetchGroupDetails(); // Fetch latest group details
  }

  Future<void> _fetchGroupDetails() async {
    setState(() => _isLoading = true);

    try {
      DocumentSnapshot groupSnapshot =
          await _firestore.collection('groupChats').doc(widget.groupId).get();

      if (groupSnapshot.exists) {
        var groupData = groupSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _groupNameController.text = groupData['name'] ?? widget.groupName;
          _newGroupImage = groupData['image'] ?? widget.groupImage;
          _updatedMembers = List.from(groupData['members'] ?? widget.members);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch group details: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String fileName =
          "${widget.groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload to Firebase Storage
      setState(() => _isLoading = true);
      UploadTask uploadTask =
          FirebaseStorage.instance.ref("group_images/$fileName").putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _newGroupImage = imageUrl;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _firestore.collection('groupChats').doc(widget.groupId).update({
          'name': _groupNameController.text.trim(),
          'image': _newGroupImage ?? widget.groupImage,
          'members': _updatedMembers,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group updated successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update group: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Group Image
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _newGroupImage != null
                          ? NetworkImage(_newGroupImage!)
                          : widget.groupImage.isNotEmpty
                              ? NetworkImage(widget.groupImage)
                              : null,
                      backgroundColor: Colors.grey[300],
                      child: _newGroupImage == null && widget.groupImage.isEmpty
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // // Group Name
                  // TextField(
                  //   controller: _groupNameController,
                  //   decoration: InputDecoration(
                  //     labelText: "Group Name",
                  //     border: OutlineInputBorder(),
                  //   ),
                  // ),
                  Form(
                    key: _formKey,
                    child: MyTextfield(
                      hintText: 'Group Name',
                      obscureText: false,
                      controller: _groupNameController,
                      focusNode: null,
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5)),
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      textColor: Theme.of(context).colorScheme.onBackground,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter group name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Members List
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Members',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _updatedMembers.length,
                    itemBuilder: (context, index) {
                      final memberId = _updatedMembers[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future:
                            _firestore.collection('users').doc(memberId).get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const ListTile(
                              title: Text("Loading..."),
                              leading: CircleAvatar(child: Icon(Icons.person)),
                            );
                          }
                          final user = snapshot.data!;
                          final userName = user['name'] ?? "Unknown User";
                          final userProfilePic = user['profilePic'] ?? "";

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: userProfilePic.isNotEmpty
                                  ? NetworkImage(userProfilePic)
                                  : null,
                              child: userProfilePic.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(userName),
                            trailing: memberId != widget.adminId
                                ? IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _updatedMembers.remove(memberId);
                                      });
                                    },
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addnewUsers(context),
        child: Icon(FlutterRemix.add_circle_line),
      ),
    );
  }

  void _addnewUsers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Users to Group"),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Adjust height as needed
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _buildUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var users = snapshot.data!;
                    return users.length == 0
                        ? Center(
                            child: Text("No users avilabe"),
                          )
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              var user = users[index];
                              String userId = user['uid'];
                              String username = user['name'];
                              String email = user['email'];
                              String profilePic = user['profilePic'] ??
                                  "https://via.placeholder.com/150";

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(profilePic),
                                  radius: 20,
                                ),
                                subtitle: Text(email,
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Checkbox(
                                  value: selectedUsers.contains(userId),
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        selectedUsers.add(userId);
                                      } else {
                                        selectedUsers.remove(userId);
                                      }
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              );
                            },
                          );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _updatedMembers.addAll(selectedUsers);
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _buildUsers() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap((snapshot) async {
      // Get blocked userIds
      final blockUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // Get the current user's following list
      final followingList =
          await ChatServices().getFollowingList(currentUser.uid);

      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockUserIds.contains(doc.id) &&
              followingList.contains(doc.id) &&
              !_updatedMembers.contains(doc.id)) // Exclude group members
          .map((doc) => {
                'uid': doc.id,
                'name': doc.data()['name'],
                'email': doc.data()['email'],
                'profilePic': doc.data()['profilePic']
              })
          .toList();
    });
  }
}
