import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/controllers/navigation_controller.dart';
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
  final NavigationController _navigationController =
      Get.find<NavigationController>();
  bool isLoading = false;
  File? _imageFile;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => _uploadPost(),
              icon: Icon(FlutterRemix
                  .upload_cloud_2_fill), // Filled icon for better visibility
              color: theme.primary,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          'N E W  P O S T',
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main content of the page
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Image Preview with Gradient Overlay
                  if (_imageFile != null)
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Select Image Button
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(FlutterRemix.image_add_fill,
                        color: theme.onPrimary),
                    label: Text(
                      "Select Image",
                      style: TextStyle(
                        color: theme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Caption Text Field
                  Form(
                    key: _formKey,
                    child: MyTextfield(
                      editable: !isLoading,
                      hintText: 'Enter caption for your post...',
                      obscureText: false,
                      controller: _captionController,
                      focusNode: null,
                      textColor: theme
                          .onBackground, // Rounded corners for the text field
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the caption';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          // if (isLoading) _showUploadingDialog(),
          // Container(
          //   color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
          //   child: Center(
          //     child: CircularProgressIndicator(
          //       color: theme.primary, // Spinner color
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_imageFile == null || _captionController.text.isEmpty) {
        Get.snackbar("Post", "Please select an image ",
            colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      setState(() => isLoading = true);

      // Show uploading dialog
      await _showUploadingDialog(); // Ensure it's awaited before proceeding

      try {
        final imgUrl =
            await StorageService().uploadImage(_imageFile!, "user_posts");

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
        Navigator.pop(context); //navigate to home page after post uploaded

        Get.back(); // Close the uploading dialog
        Get.snackbar("Post", "Post uploaded successfully!",
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);

        setState(() {
          isLoading = false;
          _imageFile = null;
          _captionController.clear();
          _navigationController.currentIndex.value = 0;
        });
      } catch (e) {
        Get.back(); // Close the uploading dialog on error
        Get.snackbar("Post", "Failed to upload post: $e",
            colorText: Colors.red, snackPosition: SnackPosition.BOTTOM);

        setState(() => isLoading = false);
        Navigator.pop(context);
      }
    }
  }

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

  Future<void> _showUploadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'lib/assets/uploading_animation.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Upload Status Text
                  AnimatedTextKit(totalRepeatCount: 3, animatedTexts: [
                    TyperAnimatedText(
                      speed: Duration(milliseconds: 150),
                      "Uploading Post...",
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
                  // const Text(
                  //   'Uploading Post...',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
