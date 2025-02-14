import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../model/comments_model.dart';
import '../../model/post_model.dart';

class PostServices {
  // final StorageService _storageService=StorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadPost({required PostModel model}) async {
    await _firestore.collection("posts").doc(model.postId).set(model.toJson());
  }

  Future<void> deletePost({required String postId}) async {
    await _firestore.collection("posts").doc(postId).delete();
  }

  Future<void> toggleLike(
      {required String postId, required String userId}) async {
    try {
      final postDoc = await _firestore.collection("posts").doc(postId).get();
      if (postDoc.exists) {
        final post = PostModel.fromJson(postDoc.data() as Map<String, dynamic>);

        //   check if user has already liked the post or not
        final hasLiked = post.likes.contains(userId);

        // update the  like list
        if (hasLiked) {
          post.likes.remove(userId); //unlike the post
        } else {
          post.likes.add(userId); //liking the post
        }
        //   update post document with likes list
        await _firestore
            .collection("posts")
            .doc(postId)
            .update({'likes': post.likes});
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      // print('Error : $e');
      throw Exception(e);
    }
  }

  // Add a bookmark for the current user
  Future<void> addBookmark({required PostModel model}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Add the post to the user's bookmarks subcollection
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("bookmarks")
          .doc(model.postId) // Use postId as the document ID
          .set(model.toJson());

      print('Bookmark added successfully!');
    } catch (e) {
      print('Error adding bookmark: $e');
      // Optionally, rethrow the error or handle it in a user-friendly way
      throw Exception('Failed to add bookmark: $e');
    }
  }

  // Remove a bookmark for the current user
  Future<void> removeBookmark({required String postId}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Remove the post from the user's bookmarks subcollection
      await _firestore
          .collection("users")
          .doc(userId)
          .collection("bookmarks")
          .doc(postId)
          .delete();

      print('Bookmark removed successfully!');
    } catch (e) {
      print('Error removing bookmark: $e');
      // Optionally, rethrow the error or handle it in a user-friendly way
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  Stream<List<PostModel>> getBookmarksStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
      return _firestore
        .collection("users")
        .doc(userId)
        .collection("bookmarks")
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => PostModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addComments(
      {required String postId, required CommentsModel comment}) async {
    try {
      //   fetch post document
      final postDoc = await _firestore.collection("posts").doc(postId).get();
      if (postDoc.exists) {
        final post = PostModel.fromJson(postDoc.data() as Map<String, dynamic>);
        //   add new comment
        post.comments.add(comment);
        //   update firestore
        await _firestore.collection("posts").doc(postId).update({
          'comments': post.comments
              .map(
                (comment) => comment.toJson(),
              )
              .toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      // print('Error : $e');
      throw Exception(e);
    }
  }

  Future<void> deleteComment(
      {required String postId, required String commentId}) async {
    try {
      //   fetch post document
      final postDoc = await _firestore.collection("posts").doc(postId).get();
      if (postDoc.exists) {
        final post = PostModel.fromJson(postDoc.data() as Map<String, dynamic>);
        //   add new comment
        post.comments.removeWhere((comment) => comment.id == commentId);
        //   update firestore
        await _firestore.collection("posts").doc(postId).update({
          'comments': post.comments
              .map(
                (comment) => comment.toJson(),
              )
              .toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      // print('Error : $e');
      throw Exception(e);
    }
  }
}
