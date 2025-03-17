import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../../pages/features/create_post_page.dart';
import '../../utils/page_transition/slide_up_page_transition.dart';

class CreatePostButton extends StatelessWidget {
  const CreatePostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
            context, SlideUpNavigationAnimation(child: CreatePostPage()));
      },
      icon: const Icon(FlutterRemix.add_circle_line, color: Colors.black),
      label: Text(
        'Create a Post',
        style: TextStyle(color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
