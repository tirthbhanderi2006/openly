import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../components/widgets_components/chat_bubble.dart';
import '../../components/widgets_components/my_textfield.dart';
import '../../services/chat_services/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverId;
  List<dynamic> followingList = [];

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
    listenForIncomingCalls(context, FirebaseAuth.instance.currentUser!.uid);
    node.addListener(() {
      if (node.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 500), () => scrollToBottom());
      }
    });

    // check if the user is following the receiver or not
    checkIfFollowing();
  }

  @override
  void dispose() {
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

// check checkIfFollowing
  void checkIfFollowing() async {
    widget.followingList = await ChatServices()
        .getFollowingList(FirebaseAuth.instance.currentUser!.uid);
    if (!widget.followingList.contains(widget.receiverId)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not Following this user')),
      );
    }
  }

//   for sending messages
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
        Reference storageRef =
            FirebaseStorage.instance.ref().child('chat_images/$fileName');
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

  // for video call
  void startVideoCall(
      BuildContext context, String currentUserId, String receiverId) async {
    // Generate a unique call ID
    String callID = generateCallID(currentUserId, receiverId);
    // Save call details to Firestore
    await FirebaseFirestore.instance.collection('video_calls').doc(callID).set({
      'callID': callID,
      'callerID': currentUserId,
      'receiverID': receiverId,
      'startTime': FieldValue.serverTimestamp(),
      'status': 'ongoing', // You can update this when the call ends
    });
    // Navigate to the video call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoUIKitPrebuiltCall(
          appID: 482616865, //app ID
          appSign:
              "69c2940bbaac4ae2e8d94ffc1343fde1fed742133c9cfb9eedef243e6912e5c1", //app sign
          userID: currentUserId,
          userName: FirebaseAuth.instance.currentUser!.email.toString(),
          callID: callID,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..useSpeakerWhenJoining = true,
        ),
      ),
    );
  }

  String generateCallID(String currentUserId, String receiverId) {
    // Use a consistent format for call ID (e.g., sorted alphabetically for uniqueness)
    return currentUserId.compareTo(receiverId) < 0
        ? '$currentUserId-$receiverId'
        : '$receiverId-$currentUserId';
  }

  void listenForIncomingCalls(BuildContext context, String currentUserId) {
    FirebaseFirestore.instance
        .collection('video_calls')
        .where('receiverID', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((querySnapshot) {
      for (var docChange in querySnapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          // New incoming call detected
          var callData = docChange.doc.data();
          showIncomingCallDialog(context, callData!);
        }
      }
    });
  }

  void showIncomingCallDialog(
      BuildContext context, Map<String, dynamic> callData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incoming Call'),
          content:
              Text('You have an incoming call from ${widget.receiverEmail}'),
          actions: [
            TextButton(
              onPressed: () {
                // Reject the call
                FirebaseFirestore.instance
                    .collection('video_calls')
                    .doc(callData['callID'])
                    .set({'status': 'rejected'});
                Navigator.of(context).pop();
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Accept the call
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  //here the video screen is launching
                  MaterialPageRoute(
                    builder: (context) => ZegoUIKitPrebuiltCall(
                      appID: 482616865, //app id
                      appSign:
                          "69c2940bbaac4ae2e8d94ffc1343fde1fed742133c9cfb9eedef243e6912e5c1", //app sign
                      userID: callData['receiverID'],
                      userName:
                          FirebaseAuth.instance.currentUser!.email.toString(),
                      callID: callData['callID'],
                      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                        ..useSpeakerWhenJoining = true,
                      events: ZegoUIKitPrebuiltCallEvents(
                        onCallEnd: (event, defaultAction) {
                          Navigator.pop(context);
                          FirebaseFirestore.instance
                              .collection('video_calls')
                              .doc(callData['callID'])
                              .delete();
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                'Accept',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
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
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  startVideoCall(
                      context,
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.receiverId);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {},
              ),
            ],
            automaticallyImplyLeading: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: CircleAvatar(
                backgroundImage: userMap['profilePic'] != null
                    ? NetworkImage(userMap['profilePic'])
                    : null,
                backgroundColor: userMap['profilePic'] == null
                    ? theme.colorScheme.primaryContainer
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
            titleSpacing: 2,
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
    bool isCurrentUser =
        data['senderId'] == FirebaseAuth.instance.currentUser!.uid;

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              hintStyle: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.5)),
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
              icon:
                  const Icon(FlutterRemix.image_add_fill, color: Colors.white),
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
              icon: const Icon(FlutterRemix.send_plane_2_fill,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
