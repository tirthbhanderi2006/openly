import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:mithc_koko_chat_app/components/my_textfield.dart';
import 'package:mithc_koko_chat_app/model/comments_model.dart';
import 'package:mithc_koko_chat_app/pages/profile_page.dart';
import 'package:mithc_koko_chat_app/services/chat_services.dart';
import 'package:mithc_koko_chat_app/services/post_services.dart';
import 'package:mithc_koko_chat_app/themes/theme_provider.dart';
import '../model/post_model.dart';

class PostTile extends StatefulWidget {
  final PostModel model;

  const PostTile({super.key, required this.model});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool showHeart = false;
  bool isDark = ThemeProvider().isDarkMode;
  final TextEditingController _commentController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showHeart = false;
          });
          _controller.reset();
        });
      }
    });

    _animation = Tween<double>(begin: 0.5, end: 1)
        .chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void handleDoubleTap() {
    setState(() {
      showHeart = true;
    });
    _controller.forward();
    PostServices().toggleLike(
      postId: widget.model.postId,
      userId: FirebaseAuth.instance.currentUser!.uid,
    );
  }

  Future<void> addComment(BuildContext context) async {
    final comment = CommentsModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.model.postId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      userName: await getCurrentUserName(),
      text: _commentController.text,
      timeStamp: DateTime.now(),
    );

    if (_commentController.text.isNotEmpty) {
      await PostServices().addComments(postId: widget.model.postId, comment: comment);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Comment added")));
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You cannot add an empty comment")));
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
          initialChildSize: 0.8, // Start height as a fraction of the screen
          minChildSize: 0.5, // Minimum height
          maxChildSize: 1, // Maximum height
          builder: (BuildContext context, ScrollController scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
              ),
              child: Column(
                children: [
                  // Header
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
                  // Comments List
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .doc(widget.model.postId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                            child: Text(
                              'Error loading comments.',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          );
                        }

                        final commentsData =
                            snapshot.data!.get('comments') as List<dynamic>? ?? [];
                        final comments = commentsData.map((commentData) {
                          return CommentsModel.fromJson(
                              commentData as Map<String, dynamic>);
                        }).toList();

                        if (comments.isEmpty) {
                          return Center(
                            child: Text(
                              'No comments yet.',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return GestureDetector(
                              onLongPress: () {
                                showDialog(context: context, builder: (context) {
                                  return widget.model.userId==FirebaseAuth.instance.currentUser!.uid || comment.userId == FirebaseAuth.instance.currentUser!.uid ? AlertDialog(
                                    title: Text("Delete comment"),
                                    content: Text("Are you sure you want to delete this comment?"),
                                    actions: [
                                      TextButton(onPressed: (){
                                        PostServices().deleteComment(postId: widget.model.postId, commentId: comment.id);
                                        Navigator.pop(context);
                                      }, child: Text("Delete",style: TextStyle(color: Colors.red),)),
                                      TextButton(onPressed: ()=>Navigator.pop(context), child: Text("cancel"))
                                    ],
                                  ):const SizedBox.shrink();
                                },);
                              },
                              child: ListTile(
                                leading: FutureBuilder<String>(
                                  future: getCurrentUserImage(comment.userId ==
                                      FirebaseAuth.instance.currentUser!.uid
                                      ? FirebaseAuth.instance.currentUser!.uid
                                      : comment.userId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircleAvatar(
                                        backgroundColor: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        radius: 20,
                                        child: const CircularProgressIndicator(),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data == 'No user found') {
                                      return CircleAvatar(
                                        backgroundColor:
                                        isDark ? Colors.grey[700] : Colors.grey,
                                        radius: 20,
                                        child: Icon(Icons.person,
                                            color: isDark ? Colors.white : Colors.black),
                              
                                      );
                                    }
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(snapshot.data!),
                                      radius: 20,
                                    );
                                  },
                                ),
                                title: Text(
                                  comment.userId ==
                                      FirebaseAuth.instance.currentUser!.uid
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
                                  '${comment.timeStamp.toLocal()}'.split(' ')[0],
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Add Comment Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextfield(
                            hintText: 'Write a comment...',
                            obscureText: false,
                            controller: _commentController,
                            focusNode: null,
                            hintStyle: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[700]),
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            textColor: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: isDark ? Colors.white : Colors.black,
                          onPressed: () async {
                            await addComment(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  // Profile Picture
                  FutureBuilder<String>(
                    future: getCurrentUserImage(widget.model.userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                          radius: 20,
                          child: const CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == 'No user found') {
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).dividerColor,
                          radius: 20,
                          child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                        );
                      }
                      return CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data!),
                        radius: 20,
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: widget.model.userId),
                      ),
                    ),
                    child: Text(
                      widget.model.userName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  // Delete/Block Options
                  widget.model.userId == FirebaseAuth.instance.currentUser!.uid
                      ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete!'),
                            content: const Text('Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  PostServices().deletePost(postId: widget.model.postId);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                      : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'block') {
                        ChatServices().blockUser(widget.model.userId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 10),
                            const Text('Block User'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Post Image
            GestureDetector(
              onDoubleTap: handleDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      widget.model.imgUrl,
                      fit: BoxFit.cover,
                      height: 300,
                      width: double.infinity,
                    ),
                  ),
                  if (showHeart)
                    ScaleTransition(
                      scale: _animation,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          PostServices().toggleLike(
                            postId: widget.model.postId,
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          );
                        },
                        icon: Icon(
                          widget.model.likes.contains(FirebaseAuth.instance.currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        widget.model.likes.length.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () => openCommentSheet(context),
                        icon: const Icon(Icons.comment_outlined),
                      ),
                      Text(
                        widget.model.comments.length.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Handle share action
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                    ],
                  ),
                  if (widget.model.caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.model.caption,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                      ),
                    ),
                  Text(
                    'Posted on ${widget.model.timeStamp}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
  // Function to get the current user's profile picture URL
  Future<String> getCurrentUserImage(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

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
}
