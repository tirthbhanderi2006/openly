import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:mithc_koko_chat_app/services/chat_services/chat_services.dart';
import 'package:dio/dio.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  final String? imageUrl;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.userId,
    required this.messageId,
    this.imageUrl,
  });

  // Show options
  void _showOption(
      {required BuildContext context,
      required String userId,
      required String messageId,
      String? imgPath}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Report button
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportContent(
                      context: context, userId: userId, messageId: messageId);
                },
              ),
              // Block user
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(userId: userId, context: context);
                },
              ),
              imgPath != null && imgPath.isNotEmpty
                  ? ListTile(
                      leading: const Icon(Icons.save),
                      title: const Text('Save Image'),
                      onTap: () =>
                          _saveImage(imgPath: imgPath, context: context),
                    )
                  : SizedBox(),
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
  void _reportContent(
      {required BuildContext context,
      required String userId,
      required String messageId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: const Text('Are you sure you want to report this message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ChatServices().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message Reported')));
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
  void _blockUser({required BuildContext context, required String userId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ChatServices().blockUser(userId);
              Navigator.pop(context); // For dialog
              Navigator.pop(context); // To pop out chat page
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('User Blocked')));
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

// save image
  void _saveImage({required String imgPath, required BuildContext context}) {
    Dio()
        .download(imgPath,
            'storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.jpg')
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image saved')));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save image')));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          // Show options
          _showOption(
              context: context,
              messageId: messageId,
              userId: userId,
              imgPath: imageUrl);
        }
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(imageUrl == null ? 12 : 4),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCurrentUser ? 12 : 0),
              topRight: Radius.circular(isCurrentUser ? 0 : 12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
            color: isCurrentUser ? Color(0xFFC0BDB8) : Color(0xFF7A7B7A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          // No decoration for images
          child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // If imageUrl is not null, show the image
              if (imageUrl != null && imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      12), // Rounded corners for chat bubble
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width *
                          0.45, // Limit width for chat bubble
                    ),
                    child: InstaImageViewer(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              ),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              color: Colors.red, size: 100);
                        },
                      ),
                    ),
                  ),
                ),

              // If imageUrl is null, show the message text
              if (imageUrl == null || imageUrl!.isEmpty)
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
