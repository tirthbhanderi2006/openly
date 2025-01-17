import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mithc_koko_chat_app/page_transition/slide_up_page_transition.dart';
import 'package:mithc_koko_chat_app/webrtc/views/video_layout.dart';


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

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool isWaitingForOtherUser = true;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    userDetailsFuture = getUserDetails(widget.receiverId);

    node.addListener(() {
      if (node.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 500), () => scrollToBottom());
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
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
            actions: [
              IconButton(
                  onPressed: () {
                    Signalling().openUserMedia(_localRenderer);
                    Navigator.push(
                        context,
                        SlideUpNavigationAnimation(
                            child: VideoLayout(
                                localRenderer: _localRenderer,
                                remoteRenderer: _remoteRenderer)));
                  },
                  icon: Icon(Icons.video_call_rounded)),
            ],
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
        );
      },
    );
  }


}
