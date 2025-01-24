import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mithc_koko_chat_app/model/message_model.dart';

class ChatServices{
//   instance of firestore
final FirebaseFirestore _firestore=FirebaseFirestore.instance;

// get all user steam
Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      // Map each document to its data and convert it into a list
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

// send message
  Future<void> sendMessage(String receiverId, String message, {String? imageUrl}) async {
    // Get current user info
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
    Timestamp timestamp = Timestamp.now();

    // Create a new message
    MessageModel model = MessageModel(
      senderId: currentUserUid,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      imageUrl: imageUrl, // Include imageUrl if provided
      timestamp: timestamp,
    );

    // Create a new chatRoom ID
    List<String> ids = [currentUserUid, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Add message to chatRoom
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(model.toMap());
  }


// get message
Stream<QuerySnapshot<Object?>> getMessages(String userId, String otherUserId) {
    // Construct a chat room ID by sorting user IDs and joining with '_'
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Return a stream of messages ordered by timestamp
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

// get all users expect blocked user steam
  Stream<List<Map<String, dynamic>>> getUserStreamExcludingBlocked() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return _firestore.collection("users").doc(currentUser!.uid).collection("BlockedUsers").snapshots().asyncMap((snapshot) async {
      // Get blocked userIds
      final blockUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // Get the current user's following list
      final followingList = await getFollowingList(currentUser.uid);

      // Get all users
      final usersSnapshot = await _firestore.collection("users").get();

      return usersSnapshot.docs
          .where((doc) =>
      doc.data()['email'] != currentUser.email &&
          !blockUserIds.contains(doc.id) &&
          followingList.contains(doc.id)
      )
          .map((doc) => doc.data())
          .toList();
    });
  }

// Function to get the current user's username
  Future<List<dynamic>> getFollowingList(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        // print("Following: ${userDetails['following']}");
        return userDetails["following"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      // print("Error : $e");
      return [];
    }
  }


//report user
Future<void> reportUser(String messageId,String userId)async{
  String currentuserId=FirebaseAuth.instance.currentUser!.uid;
  final report={
    'reportedBy':currentuserId,
    'messageId':messageId,
    'messageOwnerId':userId,
    'timestamp':Timestamp.now()
  };
  await _firestore.collection("Reports").add(report);
}

// block user
Future<void> blockUser(String userId)async{
  String currentuserId=FirebaseAuth.instance.currentUser!.uid;
  await _firestore.collection("users")
      .doc(currentuserId)
      .collection("BlockedUsers")
      .doc(userId)
      .set({});
// notifyListeners();
}

// unblock user
  Future<void> unblockUser(String blockeduserId)async{
    String currentuserId=FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection("users")
        .doc(currentuserId)
        .collection("BlockedUsers")
        .doc(blockeduserId)
        .delete();
        // notifyListeners();
  }

// get blocked user stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("BlockedUsers")
        .snapshots().asyncMap((snapshot)async{
    //       get blocked user ids
      final blockeduserId=snapshot.docs.map((doc) =>doc.id ,).toList();
      final userDocs=await Future.wait(
        blockeduserId.map((id) => _firestore.collection("users").doc(id).get(),)
      );
      // return a list
      return userDocs.map((doc) => doc.data() as Map<String,dynamic>,).toList();
    });
  }
}