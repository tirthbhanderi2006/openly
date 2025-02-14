import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/chat_components/full_image_preview.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:dio/dio.dart';
import 'package:mithc_koko_chat_app/utils/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/utils/themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  final String? imageUrl;
  final String reciverId;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.userId,
      required this.messageId,
      this.imageUrl,
      required this.reciverId});

  // Show options
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
                    Navigator.pop(context);
                    _reportContent(
                      context: context,
                      userId: userId,
                      messageId: messageId,
                    );
                  },
                ),
              if (userId != FirebaseAuth.instance.currentUser!.uid)
                // Block user
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    _blockUser(userId: userId, context: context);
                  },
                ),
              //save image
              if (imgPath != null && imgPath.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.save),
                  title: const Text('Save Image'),
                  onTap: () => _saveImage(imgPath: imgPath, context: context),
                ),
              //delete message only for sender
              if (userId == FirebaseAuth.instance.currentUser!.uid)
                ListTile(
                  leading: const Icon(
                    FlutterRemix.delete_bin_line,
                    color: Colors.red,
                  ),
                  title: const Text("Delete this message from chat ? "),
                  onTap: () => _deleteMessage(
                      messageId: messageId,
                      currentuserId: FirebaseAuth.instance.currentUser!.uid,
                      receiverId: reciverId,
                      context: context),
                ),
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

  // Block user
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
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Save image
  void _saveImage({
    required String imgPath,
    required BuildContext context,
  }) {
    Dio()
        .download(
      imgPath,
      'storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.jpg',
    )
        .then((value) {
      Navigator.pop(context);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Image saved')),
      // );
      Get.snackbar("Save", "Image saved to downloads",
          snackPosition: SnackPosition.BOTTOM);
    }).catchError((error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to save image')),
      // );
      Get.snackbar("Save", "Failed to save image",
          colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeProvider().isDarkMode;
    final backgroundColor = isCurrentUser
        ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.grey.shade300)
        : (isDarkMode ? Colors.grey.shade800 : Colors.white);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onLongPress: () {
        _showOption(
          context: context,
          messageId: messageId,
          userId: userId,
          imgPath: imageUrl,
        );
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(imageUrl == null ? 14 : 6),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCurrentUser ? 14 : 0),
              topRight: Radius.circular(isCurrentUser ? 0 : 14),
              bottomLeft: const Radius.circular(14),
              bottomRight: const Radius.circular(14),
            ),
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          SlideUpNavigationAnimation(
                              child: FullScreenImage(imageUrl: imageUrl!)));
                    },
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.35,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              if (imageUrl == null || imageUrl!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _deleteMessage(
      {required String messageId,
      required String currentuserId,
      required String receiverId,
      required BuildContext context}) {
    ChatServices().deleteMessage(
        messageId: messageId,
        currentuserId: currentuserId,
        receiverId: receiverId);
    Navigator.pop(context);
  }
}
