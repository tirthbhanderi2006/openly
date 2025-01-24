import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/model/post_model.dart';
import 'package:mithc_koko_chat_app/services/features_services/post_services.dart';
import 'package:mithc_koko_chat_app/services/features_services/storage_services.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  TextEditingController _captionController = TextEditingController();
  bool isLoading=false;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => _uploadPost(),
              icon: Icon(FlutterRemix.upload_cloud_2_line),
              color: theme.primary,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          'Create New Post',
          style: TextStyle(color: theme.primary),
        ),
      ),
      body: Stack(
        children: [
          // Main content of the page
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  if (_imageFile != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        height: 420,
                        width: 350,
                      ),
                    ), // Display the selected image
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(FlutterRemix.image_add_fill, color: theme.onPrimary),
                    label: Text(
                      "Select Image",
                      style: TextStyle(color: theme.onPrimary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextfield(
                    hintText: 'Enter caption for your post',
                    obscureText: false,
                    controller: _captionController,
                    focusNode: null,
                    textColor: theme.onBackground,
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.primary, // Spinner color
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    try {
      if (_imageFile == null || _captionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image and enter a caption")),
        );
        return;
      }
      setState(() {
        isLoading=true;
      });
      final imgUrl = await StorageService().uploadImage(_imageFile!, "user_posts");

      PostModel model = PostModel(
        postId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        userName: await getCurrentUserName(),
        caption: _captionController.text,
        imgUrl: imgUrl,
        timeStamp: DateTime.now(),
        likes: [],
        comments: [],
      );

      await PostServices().uploadPost(model: model);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post uploaded successfully!")),
      );

      setState(() {
        isLoading=false;
        _imageFile = null;
        _captionController.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload post: $e")),
      );
    }
  }

  Future<String> getCurrentUserName() async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

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
