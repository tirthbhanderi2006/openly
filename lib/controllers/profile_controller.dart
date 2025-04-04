import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/post_model.dart';

class ProfileController extends GetxController {
  final userDetails = {}.obs;
  final posts = <PostModel>[].obs;
  final followersCount = 0.obs;
  final followingCount = 0.obs;
  final followers = <String>[].obs;
  final following = <String>[].obs;

  StreamSubscription? _userDetailsSubscription;

  void fetchUserDetails(String userId) {
    // Cancel any existing subscription to avoid multiple listeners
    _userDetailsSubscription?.cancel();
    _userDetailsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        // Update userDetails only if it's for the correct user
        if (data['uid'] == userId) {
          userDetails.value = data;
          followersCount.value = (data['followers'] as List?)?.length ?? 0;
          followingCount.value = (data['following'] as List?)?.length ?? 0;
          followers.value = List<String>.from(data['followers'] ?? []);
          following.value = List<String>.from(data['following'] ?? []);
        }
      }
    });
  }

  @override
  void onClose() {
    // Dispose of the subscription when the controller is destroyed
    _userDetailsSubscription?.cancel();
    super.onClose();
  }

  //to refresh the profile page
  void refreshProfile(String userId) {
    fetchUserDetails(userId);
    fetchUserPosts(userId);
  }

  void fetchUserPosts(String userId) {
    // Fetch posts specific to the profile owner
    FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      final newPosts = snapshot.docs.map((doc) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      posts.value = newPosts;
    });
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final currentUserSnapshot = await transaction.get(currentUserRef);

      if (!userSnapshot.exists || !currentUserSnapshot.exists) return;

      final userFollowers = List<String>.from(userSnapshot['followers'] ?? []);
      final currentUserFollowing = List<String>.from(currentUserSnapshot['following'] ?? []);

      if (userFollowers.contains(currentUserId)) {
        // Unfollow
        userFollowers.remove(currentUserId);
        currentUserFollowing.remove(targetUserId);
      } else {
        // Follow
        userFollowers.add(currentUserId);
        currentUserFollowing.add(targetUserId);
      }

      transaction.update(userRef, {'followers': userFollowers});
      transaction.update(currentUserRef, {'following': currentUserFollowing});
    });

    // Fetch updated details for the target user after toggling follow
    fetchUserDetails(targetUserId);
  }
  Future<bool> checkVisitingUserIsBlocked(String visitingUserId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Check if the current user is blocked by the visiting user
      DocumentSnapshot blockedByVisitingUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(visitingUserId)
          .collection("BlockedUsers")
          .doc(currentUserId)
          .get();

      // Check if the visiting user is blocked by the current user
      DocumentSnapshot blockedByCurrentUser = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("BlockedUsers")
          .doc(visitingUserId)
          .get();

      // Return true if either user has blocked the other
      return blockedByVisitingUser.exists || blockedByCurrentUser.exists;
    } catch (e) {
      print("Error checking block status: $e");
      return false; // Return false in case of an error
    }
  }

}
