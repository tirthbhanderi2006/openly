import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';

class PostPreview extends StatelessWidget {
  final List<PostModel> posts;  // Assuming you have a Post model with imgUrl

  PostPreview({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog when tapped
                    },
                    child: Stack(
                      children: [
                        // Blur the background
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        // The animated image
                        Center(
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 300),
                            child: Image.network(posts[index].imgUrl),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: ListTile(
            title: Text(posts[index].imgUrl),  // Replace with your list content
          ),
        );
      },
    );
  }
}
