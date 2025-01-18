import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallScreen extends StatelessWidget {
  final String callId;

  const VideoCallScreen({required this.callId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final currentUser = FirebaseAuth.instance.currentUser;

    // Ensure user is authenticated before proceeding
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Call'),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: Text('Error: User not authenticated.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: Colors.teal,
      ),
      body: ZegoUIKitPrebuiltCall(
        appID: 482616865, // Replace with your ZEGOCLOUD AppID
        appSign:
            "69c2940bbaac4ae2e8d94ffc1343fde1fed742133c9cfb9eedef243e6912e5c1", // Replace with your ZEGOCLOUD AppSign
        userID: currentUser.uid, // Current user ID
        userName: 'User_${currentUser.uid}', // User-friendly name
        callID: callId, // Unique call ID
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}
