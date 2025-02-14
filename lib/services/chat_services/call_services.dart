import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/pages/chat/video_audio_calls/audio_call_screen.dart';
import 'package:mithc_koko_chat_app/pages/chat/video_audio_calls/video_call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallServices {


// credentials for video audio calls and group calls using Zego
  final _APP_ID = 482616865;
  final _APP_SIGN =
      '69c2940bbaac4ae2e8d94ffc1343fde1fed742133c9cfb9eedef243e6912e5c1';

  //FOR VIDEO CALLS

  void startVideoCall(
    BuildContext context, String currentUserId, String receiverId) async {
  String callID = generateCallID(currentUserId, receiverId);

  // Save call details to Firestore
  await FirebaseFirestore.instance.collection('video_calls').doc(callID).set({
    'callID': callID,
    'callerID': currentUserId,
    'receiverID': receiverId,
    'startTime': FieldValue.serverTimestamp(),
    'status': 'ongoing', // Default status
  });

  // Navigate to the video call screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VideoCallScreen(
        appID: _APP_ID,
        appSign: _APP_SIGN,
        currentUserId: currentUserId,
        callID: callID,
      ),
    ),
  );
}

  String generateCallID(String currentUserId, String receiverId) {
    // Use a consistent format for call IDs to ensure that both users generate the same ID
    return currentUserId.compareTo(receiverId) < 0
        ? '$currentUserId-$receiverId'
        : '$receiverId-$currentUserId';
  }

  void listenForIncomingVideoCalls(
      BuildContext context, String currentUserId, String receiverEmail) {
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
          showIncomingVideoCallDialog(context, callData!, receiverEmail);
        }
      }
    });
  }

  void showIncomingVideoCallDialog(BuildContext context,
      Map<String, dynamic> callData, String receiverEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incoming Call'),
          content: Text('You have an incoming call from ${receiverEmail}'),
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
                      appID: _APP_ID, //app id
                      appSign: _APP_SIGN, //app sign
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

// FOR AUDIO CALLS
void startAudioCall(
    BuildContext context, String currentUserId, String receiverId) async {
  String callID = generateCallID(currentUserId, receiverId);

  // Save call details to Firestore
  await FirebaseFirestore.instance.collection('audio_calls').doc(callID).set({
    'callID': callID,
    'callerID': currentUserId,
    'receiverID': receiverId,
    'startTime': FieldValue.serverTimestamp(),
    'status': 'ongoing', // Default status
  });

  // Navigate to the audio call screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AudioCallScreen(
        appID: _APP_ID,
        appSign: _APP_SIGN,
        currentUserId: currentUserId,
        callID: callID,
      ),
    ),
  );
}
// LISTEN FOR INCOMING CALLS
  void listenForIncomingVoiceCalls(
      BuildContext context, String currentUserId, String receiverEmail) async {
    await FirebaseFirestore.instance
        .collection('audio_calls')
        .where('receiverID', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((querySnapshot) {
      for (var docChange in querySnapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          var callData = docChange.doc.data();
          if (callData != null) {
            showIncomingAudiCallDialog(context, callData, receiverEmail);
          }
        }
      }
    });
  }

// SHOW INCOMING CALL DIALOG
  void showIncomingAudiCallDialog(BuildContext context,
      Map<String, dynamic> callData, String receiverEmail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incoming Call'),
          content: Text('You have an incoming call from ${receiverEmail}'),
          actions: [
            // Reject Call
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('audio_calls')
                    .doc(callData['callID'])
                    .update({'status': 'rejected'});
                Navigator.of(context).pop();
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),

            // Accept Call
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ZegoUIKitPrebuiltCall(
                      appID: _APP_ID, // Replace with your actual App ID
                      appSign: _APP_SIGN, // Replace with your actual App Sign
                      userID: callData['receiverID'],
                      userName:
                          FirebaseAuth.instance.currentUser!.email.toString(),
                      callID: callData['callID'],
                      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
                        ..useSpeakerWhenJoining = true,
                      events: ZegoUIKitPrebuiltCallEvents(
                        onCallEnd: (event, defaultAction) async {
                          await FirebaseFirestore.instance
                              .collection('audio_calls')
                              .doc(callData['callID'])
                              .delete();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
              child:
                  const Text('Accept', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

// Function to start a group video call
  Future<void> startGroupVideoCall(BuildContext context, String currentUserId,
      List<dynamic> participantIds) async {
    try {
      // Generate a unique call ID
      String callID = generateGroupCallID(currentUserId);

      // Store call details in Firestore
      await FirebaseFirestore.instance
          .collection('group_video_calls')
          .doc(callID)
          .set({
        'callID': callID,
        'hostID': currentUserId,
        'participants': participantIds,
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });

      // Navigate to the video call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZegoUIKitPrebuiltCall(
            appID: _APP_ID, // Your ZegoCloud app ID
            appSign: _APP_SIGN, // Your ZegoCloud app sign
            userID: currentUserId,
            userName: FirebaseAuth.instance.currentUser!.email.toString(),
            callID: callID,
            config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()
              ..useSpeakerWhenJoining = true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error starting group video call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to start the call: ${e.toString()}")));
    }
  }

  // Function to listen for incoming group calls
  void listenForIncomingGroupVideoCalls(
      BuildContext context, String currentUserId) {
    FirebaseFirestore.instance
        .collection('group_video_calls')
        .where('participants', arrayContains: currentUserId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((querySnapshot) {
      for (var docChange in querySnapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          // New incoming call detected
          var callData = docChange.doc.data();
          if (callData!['hostID'] != currentUserId) {
            showIncomingGroupVideoCallDialog(context, callData);
          }
        }
      }
    });
  }

// Function to display an incoming call dialog
  void showIncomingGroupVideoCallDialog(
      BuildContext context, Map<String, dynamic> callData) {
    if (callData['hostID'] != FirebaseAuth.instance.currentUser!.uid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incoming Group Call'),
            content: Text('You have an incoming group call.'),
            actions: [
              TextButton(
                onPressed: () {
                  // Reject the call
                  FirebaseFirestore.instance
                      .collection('group_video_calls')
                      .doc(callData['callID'])
                      .update({
                    'status': 'rejected',
                  });
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Reject', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  // Accept the call
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ZegoUIKitPrebuiltCall(
                        appID: _APP_ID,
                        appSign: _APP_SIGN,
                        userID: FirebaseAuth.instance.currentUser!.uid,
                        userName:
                            FirebaseAuth.instance.currentUser!.email.toString(),
                        callID: callData['callID'],
                        config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                          ..useSpeakerWhenJoining = true,
                        events: ZegoUIKitPrebuiltCallEvents(
                          onCallEnd: (event, defaultAction) {
                            Navigator.pop(context);
                            FirebaseFirestore.instance
                                .collection('group_video_calls')
                                .doc(callData['callID'])
                                .delete();
                          },
                        ),
                      ),
                    ),
                  );
                },
                child:
                    const Text('Accept', style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    } else {
      SizedBox.shrink();
    }
  }

// Helper function to generate a unique call ID
  String generateGroupCallID(String userId) {
    return "${userId}_${DateTime.now().millisecondsSinceEpoch}";
  }
}
