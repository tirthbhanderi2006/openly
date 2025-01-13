import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mithc_koko_chat_app/components/chat_bubble.dart';
import 'package:mithc_koko_chat_app/components/my_textfield.dart';
import 'package:mithc_koko_chat_app/services/chat_services.dart';

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

  @override
  void initState() {
    node.addListener(() {
      if (node.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollToBottom());
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () => scrollToBottom());
    super.initState();
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

  Widget _buildMessageList() {
    String senderId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: ChatServices().getMessages(widget.receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          controller: scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(context),
        ],
      ),
    );
  }
}
