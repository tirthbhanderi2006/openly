
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Separate Audio Call Screen with Firestore Listener
class AudioCallScreen extends StatefulWidget {
  final int appID;
  final String appSign;
  final String currentUserId;
  final String callID;

  const AudioCallScreen({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.currentUserId,
    required this.callID,
  }) : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  StreamSubscription<DocumentSnapshot>? callStatusListener;

  @override
  void initState() {
    super.initState();
    _listenForCallStatus();
  }

  void _listenForCallStatus() {
    callStatusListener = FirebaseFirestore.instance
        .collection('audio_calls')
        .doc(widget.callID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['status'] == 'rejected') {
        Navigator.pop(context); // Close audio call screen
      }
    });
  }

  @override
  void dispose() {
    callStatusListener?.cancel(); // Stop listening when screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZegoUIKitPrebuiltCall(
        appID: widget.appID,
        appSign: widget.appSign,
        userID: widget.currentUserId,
        userName: FirebaseAuth.instance.currentUser!.email.toString(),
        callID: widget.callID,
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}