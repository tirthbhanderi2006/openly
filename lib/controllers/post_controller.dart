import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/model/comments_model.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';

class PostController extends GetxController {
  final PostServices _postServices = PostServices();

  late PostModel post;
  final RxBool isLiked = false.obs;
  final RxBool isBookmarked = false.obs;
  final RxList<String> likes = <String>[].obs;
  final RxBool isLoading = false.obs;
  var isDownloading = false.obs; // To track if downloading is in progress
  var isDownloadComplete = false.obs; // To track if download is completed
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PostController(this.post) {
    initPost(post);
  }

  void initPost(PostModel post) {
    likes.value = post.likes;
    // Add null check for currentUser to prevent null exception after logout
    final currentUser = FirebaseAuth.instance.currentUser;
    isLiked.value = currentUser != null && post.likes.contains(currentUser.uid);
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      isLoading.value = true;
      // Optimistic update
      isLiked.value = !isLiked.value;
      if (isLiked.value) {
        likes.add(userId);
      } else {
        likes.remove(userId);
      }

      await _postServices.toggleLike(postId: postId, userId: userId);
    } catch (e) {
      // Revert optimistic update on error
      isLiked.value = !isLiked.value;
      if (isLiked.value) {
        likes.add(userId);
      } else {
        likes.remove(userId);
      }
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBookmark(
      {required PostModel model, required BuildContext context}) async {
    try {
      await _postServices.addBookmark(model: model);
      isBookmarked.value = true;
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text('Post added to bookmarks!')));
      Get.snackbar(
        "Bookmarks",
        "Post added to bookmarks!",
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error : $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error in adding post to bookmarks!')));
      Get.snackbar(
        "Bookmarks",
        "Error in adding post to bookmarks!",
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeBookmark(
      {required String postId, required BuildContext context}) async {
    try {
      await _postServices.removeBookmark(postId: postId);
      isBookmarked.value = false;
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Post removed from bookmarks!')));
      Get.snackbar("Bookmarks", "Post removed from bookmarks!",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.green);
    } catch (e) {
      print('Error : $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error in removing post from bookmarks!')));
      Get.snackbar("Bookmarks", "Error in removing post from bookmarks!",
          colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void openCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (BuildContext context, ScrollController scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildCommentsList(context, scrollController, isDark),
                  _buildAddCommentSection(context, isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          height: 4,
          width: 40,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCommentsList(
    BuildContext context,
    ScrollController scrollController,
    bool isDark,
  ) {
    return Expanded(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(post.postId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorWidget(isDark, 'Error loading comments.');
          }

          final commentsData =
              snapshot.data!.get('comments') as List<dynamic>? ?? [];
          final comments = commentsData
              .map((commentData) =>
                  CommentsModel.fromJson(commentData as Map<String, dynamic>))
              .toList();

          if (comments.isEmpty) {
            return _buildErrorWidget(isDark, 'No comments yet.');
          }

          return ListView.builder(
            controller: scrollController,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return _buildCommentTile(context, comments[index], isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentTile(
      BuildContext context, CommentsModel comment, bool isDark) {
    return GestureDetector(
      onLongPress: () => _showDeleteCommentDialog(context, comment, isDark),
      child: ListTile(
        leading: FutureBuilder<String>(
          future: getCurrentUserImage(comment.userId),
          builder: (context, snapshot) {
            return CircleAvatar(
              backgroundImage: snapshot.hasData
                  ? CachedNetworkImageProvider(snapshot.data!)
                  : null,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              child: !snapshot.hasData
                  ? Icon(Icons.person,
                      color: isDark ? Colors.white : Colors.black)
                  : null,
            );
          },
        ),
        title: Text(
          comment.userId == FirebaseAuth.instance.currentUser!.uid
              ? '${comment.userName}(you)'
              : comment.userName,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          comment.text,
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.black,
          ),
        ),
        trailing: Text(
          comment.timeStamp.toLocal().toString().split(' ')[0],
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showDeleteCommentDialog(
      BuildContext context, CommentsModel comment, bool isDark) {
    final isCurrentUser =
        comment.userId == FirebaseAuth.instance.currentUser!.uid;
    final isPostOwner = post.userId == FirebaseAuth.instance.currentUser!.uid;

    if (isCurrentUser || isPostOwner) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete comment"),
            content:
                const Text("Are you sure you want to delete this comment?"),
            actions: [
              TextButton(
                onPressed: () {
                  PostServices().deleteComment(
                    postId: post.postId,
                    commentId: comment.id,
                  );
                  Navigator.pop(context);
                  FocusScope.of(context)
                      .unfocus(); // remove the focus from the textfield
                },
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildErrorWidget(bool isDark, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildAddCommentSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: MyTextfield(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "you cannnot add empty comment";
                  }
                },
                obscureText: false,
                focusNode: null,
                hintText: 'Write a comment...',
                controller: _commentController,
                hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700]),
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                textColor: isDark ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: isDark ? Colors.white : Colors.black,
              onPressed: () =>
                  addComment(context: context, postId: post.postId),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addComment({required context, required String postId}) async {
    final comment = CommentsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      userName: await getCurrentUserName(),
      text: _commentController.text,
      timeStamp: DateTime.now(),
    );
    if (_formKey.currentState!.validate()) {
      if (_commentController.text.isNotEmpty) {
        await PostServices().addComments(postId: postId, comment: comment);
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(const SnackBar(content: Text("Comment added")));
        Get.snackbar("Comment", "Comment added",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green);
        _commentController.clear();

        FocusScope.of(context).unfocus(); // Close the keyboard
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text("You cannot add an empty comment")));
        Get.snackbar("Comment", "You cannot add an empty comment",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> downloadImage(
      {required String imgurl, required BuildContext context}) async {
    isDownloading.value = true; // Show downloading state

    try {
      await Dio().download(imgurl,
          'storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.jpg');
      isDownloadComplete.value = true; // Update to success state
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(const SnackBar(content: Text('Image saved')));
      Get.snackbar("Save", "Image saved to downloads",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.green);
    } catch (error) {
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(const SnackBar(content: Text('Failed to save image')));
      Get.snackbar("Save", "Failed to save image",
          colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isDownloading.value = false; // Reset downloading state
      await Future.delayed(const Duration(seconds: 2));
      isDownloadComplete.value = false; // Reset to normal state after 2 seconds
    }
  }

  // Function to get the current user's profile picture URL
  Future<String> getCurrentUserImage(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        return userDetails["profilePic"] ?? '';
      } else {
        return 'No user found';
      }
    } catch (e) {
      return 'Error fetching profile picture';
    }
  }

// function to get the current user's username
  Future<String> getCurrentUserName() async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var userDetails = snapshot.data() as Map<String, dynamic>;
        return userDetails["name"] ?? 'No username found';
      } else {
        return 'No user found';
      }
    } catch (e) {
      return 'Error fetching username';
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
  }
}
