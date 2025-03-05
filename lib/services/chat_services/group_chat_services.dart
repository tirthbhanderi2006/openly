import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/model/message_model.dart';

class GroupChatServises {
  /// Fetch all groups where the current user is a member
  Stream<QuerySnapshot> fetchUserGroups() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('groupChats')
        .where('members',
            arrayContains: userId) // Get groups where user is a member
        .snapshots();
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String message,
    String? imageUrl,
  }) async {
    // Get current user info
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    Timestamp timestamp = Timestamp.now();

    // Create a new message model
    MessageModel model = MessageModel(
      senderId: currentUserUid,
      senderEmail: currentUserEmail,
      receiverId: null, // Not needed for group chats
      groupId: groupId, // Required for group messages
      message: message,
      imageUrl: imageUrl,
      timestamp: timestamp,
    );

    // Store message in Firestore under the specific group chat
    await FirebaseFirestore.instance
        .collection("group_chats")
        .doc(groupId)
        .collection("messages")
        .add(model.toMap());
  }

  Future<void> leaveGroup(
      {required String userId, required String groupId}) async {
    // Check if the user is the admin of the group
    final groupDoc = await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupId)
        .get();
    if (groupDoc.exists) {
      final data = groupDoc.data() as Map<String, dynamic>;
      if (data['createdBy'] == userId) {
        // If the user is the admin, delete the whole group
        await FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupId)
            .delete();
      } else {
        // If the user is not the admin, remove them from the group members array
        await FirebaseFirestore.instance
            .collection('groupChats')
            .doc(groupId)
            .update({
          'members': FieldValue.arrayRemove([userId])
        });
      }
    }
  }

  // fetch all shared images:
  Future<List<String>> fetchAllsharedImages({required String groupId}) async {
    try {
      List<String> imageUrl = [];
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("group_chats")
          .doc(groupId)
          .collection("messages")
          .where("imageUrl", isNotEqualTo: null)
          .get();

      for (var doc in snapshot.docs) {
        if (doc['imageUrl'] != null) {
          imageUrl.add(doc['imageUrl']);
        }
      }
      return imageUrl;
    } catch (e) {
      print('Error in group images fetching : $e');
      return [];
    }
  }

  // delteting a message from chat screen
  Future<void> deleteMessageFromGroup(
      {required String messageID, required String groupID}) async {
    await FirebaseFirestore.instance
        .collection("group_chats")
        .doc(groupID)
        .collection("messages")
        .doc(messageID)
        .delete();
    Get.snackbar("Message", "Messages deleted !!",
        colorText: Colors.white, backgroundColor: Colors.green);
  }

  // save image to local gallery
  Future<void> saveImageToGallery(
      {required String imgPath, required BuildContext context}) async {
    Dio()
        .download(imgPath,
            'storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.jpg')
        .then(
      (value) {
        Navigator.pop(context);
        Get.snackbar("Save", "Image saved to downloads",
          colorText: Colors.white,
          backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      },
    ).onError(
      (error, stackTrace) {
        Get.snackbar("Save", "Failed to save image",
            colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
        Navigator.pop(context);
      },
    );
  }
}
