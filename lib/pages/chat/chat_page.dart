import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mithc_koko_chat_app/components/chat_components/chat_bubble.dart';
import 'package:mithc_koko_chat_app/controllers/chat_background_controller.dart';
import 'package:mithc_koko_chat_app/pages/chat/image_grid.dart';
import 'package:mithc_koko_chat_app/pages/profile/profile_page.dart';
import 'package:mithc_koko_chat_app/pages/settings/setting_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services/call_services.dart';
import 'package:mithc_koko_chat_app/utils/chat_utils/chat_utils.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';
import '../../services/chat_services/chat_services.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;
  List<dynamic> followingList = [];

  ChatPage({super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<Map<String, dynamic>> _userDetailsFuture;
  final ChatBackgroundController backgroundController =
      Get.put(ChatBackgroundController());

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _getUserDetails(widget.receiverId);
    CallServices().listenForIncomingVideoCalls(
        context, FirebaseAuth.instance.currentUser!.uid, widget.receiverEmail);
    CallServices().listenForIncomingVoiceCalls(
        context, FirebaseAuth.instance.currentUser!.uid, widget.receiverEmail);
    _focusNode.addListener(_onFocusChange);
    _checkIfFollowing();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
        _scrollToBottom();
      },
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
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

  void _checkIfFollowing() async {
    widget.followingList = await ChatServices()
        .getFollowingList(FirebaseAuth.instance.currentUser!.uid);
    if (!widget.followingList.contains(widget.receiverId)) {
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('You are not following this user')),
      // );
      Get.snackbar("Chat", "You are not following this user",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      return snapshot.data() as Map<String, dynamic>? ?? {};
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  Future<void> _sendMessage(BuildContext context, {String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('You cannot send an empty message')),
      // );
      Get.snackbar("Message", "You cannot send an empty message",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await ChatServices().sendMessage(
      widget.receiverId,
      _messageController.text.trim(),
      imageUrl: imageUrl,
    );

    _messageController.clear();
    _scrollToBottom();
    if (imageUrl != null) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Image sent successfully')),
      // );
      Get.snackbar("Message", "Image sent successfully!",
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
      Navigator.pop(context);
    }
  }

  Future<void> _pickAndSendImage({required bool isCamera}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    if (image != null) {
      try {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Uploading image...')),
        // );
        Get.snackbar("Message", "Uploading image",
            snackPosition: SnackPosition.BOTTOM);
        await _showUploadingDialog();

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('chat_images/$fileName');
        await storageRef.putFile(File(image.path));
        String imageUrl = await storageRef.getDownloadURL();

        await _sendMessage(context, imageUrl: imageUrl);
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to send image: ${e.toString()}')),
        // );
        Get.snackbar("Message", "Failed to send image: ${e.toString()}",
            snackPosition: SnackPosition.BOTTOM, colorText: Colors.red);
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('No image selected')),
      // );
      Get.snackbar("Message", "No image selected",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            // backgroundColor: theme.colorScheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: Center(
              child: Text(
                snapshot.hasError
                    ? "Error: ${snapshot.error}"
                    : "User not found.",
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
          );
        }

        Map<String, dynamic> userMap = snapshot.data!;

        return Scaffold(
          appBar: _buildAppBar(context, userMap, theme),
          extendBodyBehindAppBar: true,
          body: Obx(() => DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: backgroundController
                            .backgroundImagePath.value.isNotEmpty
                        ? FileImage(File(
                                backgroundController.backgroundImagePath.value))
                            as ImageProvider
                        : AssetImage(ThemeProvider().isDarkMode
                            ? 'lib/assets/dark-theme-chat.jpg'
                            : 'lib/assets/light-theme-chat.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(child: _buildMessageList()),
                    _buildUserInput(context),
                  ],
                ),
              )),
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context, Map<String, dynamic> userMap, ThemeData theme) {
    return AppBar(
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_outlined,
              color: ThemeProvider().isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            CallServices().startVideoCall(
              context,
              FirebaseAuth.instance.currentUser!.uid,
              widget.receiverId,
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear-chat') {
              _clearChat(
                  context: context,
                  currentUserId: FirebaseAuth.instance.currentUser!.uid,
                  receiverId: widget.receiverId);
              // ChatServices().clearChat(
              //     FirebaseAuth.instance.currentUser!.uid, widget.receiverId);
            } else if (value == 'block-user') {
              _blockUser(context: context, userId: widget.receiverId);
            } else if (value == 'settings') {
              Navigator.push(
                  context, SlideUpNavigationAnimation(child: SettingPage()));
            } else if (value == 'voice-call') {
              CallServices().startAudioCall(context,
                  FirebaseAuth.instance.currentUser!.uid, widget.receiverId);
            } else if (value == 'remove-bg') {
              backgroundController.removeBackground();
            }
          },
          itemBuilder: (BuildContext context) => [
            //voice call feature
            PopupMenuItem<String>(
              value: 'voice-call',
              child: Row(
                children: [
                  Icon(
                    Icons.call, // FlutterRemix icon for clear chat
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Voice call',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Clear Chat Option
            PopupMenuItem<String>(
              value: 'clear-chat',
              child: Row(
                children: [
                  Icon(
                    FlutterRemix
                        .delete_bin_line, // FlutterRemix icon for clear chat
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Clear Chat',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // reomoe chat bg
            PopupMenuItem<String>(
              value: 'remove-bg',
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    // FlutterRemix icon for remove background
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
            // Block User Option
            PopupMenuItem<String>(
              value: 'block-user',
              child: Row(
                children: [
                  Icon(
                    FlutterRemix
                        .user_unfollow_line, // FlutterRemix icon for block user
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Block User',
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
          ],
        )
      ],
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: ThemeProvider().isDarkMode ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => ChatUtils.showProfileDialog(
                context, userMap['profilePic'], widget.receiverId),
            child: CircleAvatar(
              backgroundImage: userMap['profilePic'] != null
                  ? CachedNetworkImageProvider(userMap['profilePic'])
                  : null,
              backgroundColor: userMap['profilePic'] == null
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
              child: userMap['profilePic'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              List<String> imageUrls = await ChatServices().fetchSharedImages(
                senderId: FirebaseAuth.instance.currentUser!.uid,
                receiverId: widget.receiverId,
              );
              Navigator.push(
                  context,
                  SlideUpNavigationAnimation(
                      child: ImageGrid(imageUrls: imageUrls)));
            },
            child: Text(
              userMap['name'] ?? "Unknown User",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: ChatServices().getMessages(widget.receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: ChatUtils.emptyChatWidget(context));
        }
        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data['senderId'] == FirebaseAuth.instance.currentUser!.uid;

    return ChatBubble(
      message: data['message'],
      isCurrentUser: isCurrentUser,
      userId: data['senderId'],
      messageId: doc.id,
      imageUrl: data['imageUrl'],
      reciverId: data['receiverId'],
    );
  }

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
                    border: InputBorder.none,
                    // Remove default border
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    filled: true,
                    fillColor: Colors.transparent, // Transparent background
                  ),
                  maxLines: null,
                  // Allow multiple lines
                  keyboardType: TextInputType.multiline,
                  // Enable multiline input
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
            // Camera Option Button with Animation
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
              onPressed: () => _sendMessage(context),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // block user via popup menu
  void _blockUser({
    required BuildContext context,
    required String userId,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatServices().blockUser(userId);
              Navigator.pop(context); // For dialog
              Navigator.pop(context); // To pop out chat page
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('User Blocked')),
              // );
              Get.snackbar("Block", "User Blocked",
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text(
              'Block',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // chat clear function via popup menu
  void _clearChat(
      {required BuildContext context,
      required String currentUserId,
      required String receiverId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
            'Are you sure you want to cleat all message from this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatServices().clearChat(currentUserId, receiverId);
              Navigator.pop(context);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Chat cleared')),
              // );
              Get.snackbar("chat", "Chat cleared!",
                  colorText: Colors.white,
                  backgroundColor: Colors.green,
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text(
              'clear chat',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  // build uploading dialog

  Future<void> _showUploadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'lib/assets/uploading_animation.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Upload Status Text
                  AnimatedTextKit(totalRepeatCount: 3, animatedTexts: [
                    TyperAnimatedText(
                      speed: Duration(milliseconds: 150),
                      "Sending Image...",
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                  // const Text(
                  //   'Uploading Post...',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
