import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/controllers/chat_background_controller.dart';
import 'package:mithc_koko_chat_app/controllers/group_chat_controller.dart';
import 'package:mithc_koko_chat_app/main.dart';
import 'package:mithc_koko_chat_app/pages/chat/group_details.dart';
import 'package:mithc_koko_chat_app/pages/chat/image_grid.dart';
import 'package:mithc_koko_chat_app/pages/settings/setting_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services/call_services.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:mithc_koko_chat_app/services/chat_services/group_chat_services.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  String groupName;
  List<dynamic> members;
  late String image;
  final String createdBy;

  GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.createdBy,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> with RouteAware {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GroupChatController groupChatController =
      Get.put(GroupChatController());
  final ChatBackgroundController chatBackgroundController =
      Get.put(ChatBackgroundController());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
        _scrollToBottom();
      },
    );
    widget.image =
        'https://imgs.search.brave.com/Hcmzrb57J7ck-0du50YeYYh_-xFH2xjERQZE43QHOSU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzFmLzIw/L2YzLzFmMjBmMzVm/ZTcyMmVlNzFlYTEx/ZjdkNzQ1MDBhODhm/LmpwZw';
    _fetchGroupDetails();
    CallServices()
        .listenForIncomingGroupVideoCalls(context, _auth.currentUser!.uid);

    groupChatController.groupName.value = widget.groupName;
    groupChatController.image.value = widget.image;
    groupChatController.members.value = widget.members;
  }

  @override
  void didChangeDependencies() {
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(
          this, modalRoute); // Subscribe to the RouteObserver
    }
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    _fetchGroupDetails();
    super.didPopNext();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    routeObserver.unsubscribe(this); // Unsubscribe from RouteObserver
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration:
            const Duration(milliseconds: 300), // Adjusted for smooth scrolling
        curve: Curves.easeInOut, // Smooth transition without bouncing
      );
    }
  }

  Future<void> _fetchGroupDetails() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        var groupData = groupSnapshot.data() as Map<String, dynamic>;
        // setState(() {
        //   widget.image = groupData['image'];
        //   widget.groupName = groupData['name'] ?? widget.groupName;
        //   widget.members = List.from(groupData['members'] ?? widget.members);
        // });
        groupChatController.image.value = groupData['image'];
        groupChatController.groupName.value =
            groupData['name'] ?? widget.groupName;
        groupChatController.members.value =
            List.from(groupData['members'] ?? widget.members);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch group details: $e")),
      );
    } finally {}
  }

  // Send message using your existing method
  Future<void> _sendMessage({String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    await GroupChatServises().sendGroupMessage(
      groupId: widget.groupId,
      message: _messageController.text.trim(),
      imageUrl: imageUrl,
    );

    // Clear message field
    _messageController.clear();
  }

  // Upload image to Firebase Storage & get the URL
  Future<void> _pickAndSendImage({required bool isCamera}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String fileName =
          "${widget.groupId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("group_chats/${widget.groupId}/$fileName")
          .putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Send message with image URL
      _sendMessage(imageUrl: imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    // String imageAsset = ThemeProvider().isDarkMode
    //     ? 'lib/assets/dark-theme-chat.jpg'
    //     : 'lib/assets/light-theme-chat.jpg';
    return Scaffold(
      appBar: _buildAppBar(context, Theme.of(context)),
      body: Obx(
        () => DecoratedBox(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: chatBackgroundController
                          .backgroundImagePath.value.isNotEmpty
                      ? FileImage(File(chatBackgroundController
                          .backgroundImagePath.value)) as ImageProvider
                      : AssetImage(ThemeProvider().isDarkMode
                          ? 'lib/assets/dark-theme-chat.jpg'
                          : 'lib/assets/light-theme-chat.jpg'),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              //  Display messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("group_chats")
                      .doc(widget.groupId)
                      .collection("messages")
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var msg =
                            messages[index].data() as Map<String, dynamic>;
                        bool isMe = msg['senderId'] == _auth.currentUser!.uid;

                        return GestureDetector(
                          onLongPress: () => _showOption(
                              context: context,
                              userId: msg['senderId'],
                              messageId: messages[index].id),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(
                                  msg['imageUrl'] != null ? 5 : 10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sender's email
                                  Text(
                                    msg['senderEmail'],
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Image or message
                                  if (msg['imageUrl'] != null)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            SlideUpNavigationAnimation(
                                                child: FullScreenImage(
                                                    imageUrl:
                                                        msg['imageUrl'])));
                                      },
                                      onLongPress: () {
                                        _showOption(
                                            context: context,
                                            userId: msg['senderId'],
                                            messageId: messages[index].id,
                                            imgPath: msg['imageUrl']);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: msg['imageUrl'],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (msg['message'].isNotEmpty)
                                    Text(
                                      msg['message'],
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
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
              ),
              // user input for message
              _buildUserInput(context)
            ],
          ),
        ),
      ),
    );
  }

//appbar
  AppBar _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_outlined,
              color: ThemeProvider().isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            CallServices().startGroupVideoCall(
                context, _auth.currentUser!.uid, widget.members);
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'group-details') {
              Navigator.push(
                  context,
                  SlideUpNavigationAnimation(
                      child: GroupDetails(
                    groupId: widget.groupId,
                    groupName: groupChatController.groupName.value,
                    groupImage:
                        'https://imgs.search.brave.com/Hcmzrb57J7ck-0du50YeYYh_-xFH2xjERQZE43QHOSU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzFmLzIw/L2YzLzFmMjBmMzVm/ZTcyMmVlNzFlYTEx/ZjdkNzQ1MDBhODhm/LmpwZw',
                    adminId: widget.createdBy,
                    members: groupChatController.members,
                  )));
            } else if (value == 'leave-group') {
              await GroupChatServises().leaveGroup(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                  groupId: widget.groupId);
              Navigator.pop(context);
            } else if (value == 'settings') {
              Navigator.push(
                  context, SlideUpNavigationAnimation(child: SettingPage()));
            } else if (value == 'remove-bg') {
              chatBackgroundController.removeBackground();
            }
          },
          itemBuilder: (BuildContext context) => [
            // group details
            PopupMenuItem<String>(
              value: 'group-details',
              child: Row(
                children: [
                  Icon(
                    FlutterRemix.group_line,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Group details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // remove bg option
            PopupMenuItem<String>(
              value: 'remove-bg',
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Remove Background',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Settings Option
            PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    FlutterRemix
                        .settings_line, // FlutterRemix icon for settings
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // leave group
            PopupMenuItem<String>(
              value: 'leave-group',
              child: Row(
                children: [
                  Icon(
                    FlutterRemix.logout_box_r_line,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'leave group',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: ThemeProvider().isDarkMode ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Obx(
        () => Row(
          children: [
            GestureDetector(
              // onTap: () => showProfileDialog(context, userMap['profilePic']),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(groupChatController
                        .image.isEmpty
                    ? 'https://imgs.search.brave.com/Hcmzrb57J7ck-0du50YeYYh_-xFH2xjERQZE43QHOSU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzFmLzIw/L2YzLzFmMjBmMzVm/ZTcyMmVlNzFlYTEx/ZjdkNzQ1MDBhODhm/LmpwZw'
                    : groupChatController.image.value),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () async {
                List<String> imageUrls = await GroupChatServises()
                    .fetchAllsharedImages(groupId: widget.groupId);
                Navigator.push(
                    context,
                    SlideUpNavigationAnimation(
                        child: ImageGrid(imageUrls: imageUrls)));
              },
              child: Text(
                groupChatController.groupName.value ?? "Unknown Group",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    );
  }

//user input
  Widget _buildUserInput(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 16,
                    ),
                    border: InputBorder.none, // Remove default border
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    filled: true,
                    fillColor: Colors.transparent, // Transparent background
                  ),
                  maxLines: null, // Allow multiple lines
                  keyboardType:
                      TextInputType.multiline, // Enable multiline input
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Image Picker Button with Animation
            IconButton(
              icon: Icon(
                FlutterRemix.image_add_fill,
                color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
                size: 24,
              ),
              onPressed: () async {
                await _pickAndSendImage(isCamera: false);
              },
            ),
            // const SizedBox(width: ),
            IconButton(
              icon: Icon(
                FlutterRemix.camera_fill,
                color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
                size: 24,
              ),
              onPressed: () async {
                await _pickAndSendImage(isCamera: true);
              },
            ),
            // Send Button with Animation
            IconButton(
              icon: Icon(
                FlutterRemix.send_plane_fill,
                color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
                size: 24,
              ),
              onPressed: () => _sendMessage(),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

// long press options
  void _showOption({
    required BuildContext context,
    required String userId,
    required String messageId,
    String? imgPath,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Report button
              if (userId != FirebaseAuth.instance.currentUser!.uid)
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Report'),
                  onTap: () {
                    _reportContent(
                        context: context, userId: userId, messageId: messageId);
                  },
                ),
              //save image
              if (imgPath != null && imgPath.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Save Image'),
                  onTap: () {
                    GroupChatServises()
                        .saveImageToGallery(imgPath: imgPath, context: context);
                  },
                ),
              //delete message only for sender
              if (userId == FirebaseAuth.instance.currentUser!.uid)
                ListTile(
                    leading: const Icon(
                      FlutterRemix.delete_bin_line,
                      color: Colors.red,
                    ),
                    title: const Text("Delete this message from chat ? "),
                    onTap: () {
                      GroupChatServises().deleteMessageFromGroup(
                          messageID: messageId, groupID: widget.groupId);
                      Navigator.pop(context);
                    }),
              // Cancel button
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Report message
  void _reportContent({
    required BuildContext context,
    required String userId,
    required String messageId,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: const Text('Are you sure you want to report this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatServices().reportUser(messageId, userId);
              Navigator.pop(context);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Message Reported')),
              // );
              Get.snackbar("Report", "Message Reported",
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text(
              'Report',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
