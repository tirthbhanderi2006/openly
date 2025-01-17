import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../components/chat_bubble.dart';
import '../components/my_textfield.dart';
import '../services/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;

  ChatPage({super.key, required this.receiverEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FocusNode node = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late Future<Map<String, dynamic>> userDetailsFuture;

  @override
  void initState() {
    super.initState();
    userDetailsFuture = getUserDetails(widget.receiverId);

    node.addListener(() {
      if (node.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollToBottom());
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    node.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection("users").doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
  Future<void> sendMessage(BuildContext context, {String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot send an empty message')),
      );
      return;
    }

    await ChatServices().sendMessage(
      widget.receiverId,
      _messageController.text.trim(),
      imageUrl: imageUrl,
    );

    _messageController.clear();
    scrollToBottom();
    if (imageUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image sent successfully')),
      );
    }
  }

  Future<void> pickAndSendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');
        await storageRef.putFile(File(image.path));
        String imageUrl = await storageRef.getDownloadURL();

        await sendMessage(context, imageUrl: imageUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: userDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: theme.colorScheme.onBackground),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: const Center(
              child: Text("User not found."),
            ),
          );
        }

        Map<String, dynamic> userMap = snapshot.data!;

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: CircleAvatar(
                backgroundImage: userMap['profilePic'] != null
                    ? NetworkImage(userMap['profilePic'])
                    : null,
                backgroundColor: userMap['profilePic'] == null
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                child: userMap['profilePic'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
            title: Text(
              userMap['name'] ?? "Unknown User",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            centerTitle: false,
            titleSpacing: 0,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildUserInput(context),
            ],
          ),
        );
      },
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
        return ListView(
          controller: scrollController,
          children:
          snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: data['message'],
          isCurrentUser: isCurrentUser,
          userId: data['senderId'],
          messageId: doc.id,
          imageUrl: data['imageUrl'],
        ),
      ],
    );
  }

  Widget _buildUserInput(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, right: 12),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              hintText: 'Type a message',
              obscureText: false,
              controller: _messageController,
              focusNode: node,
              hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
              fillColor: theme.colorScheme.surfaceVariant,
              textColor: theme.colorScheme.onBackground,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: IconButton(
              icon: const Icon(Icons.image, color: Colors.white),
              onPressed: pickAndSendImage,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(100)),
            ),
            child: IconButton(
              onPressed: () => sendMessage(context),
              icon: const Icon(Icons.arrow_upward_outlined, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

