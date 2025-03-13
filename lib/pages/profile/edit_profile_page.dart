import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mithc_koko_chat_app/components/widgets_components/my_textfield.dart';
import 'package:mithc_koko_chat_app/services/features_services/storage_services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioTextController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _profilePicUrl;
  bool _isUpdating = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation

  Future<void> _selectProfilePicture() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        setState(() => _isUpdating = true);

        String downloadUrl =
            await StorageService().uploadImage(imageFile, 'profilePictures');

        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception("No user is currently signed in.");

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profilePic': downloadUrl,
        });

        setState(() {
          _profilePicUrl = downloadUrl;
          _isUpdating = false;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //       content: Text('Profile picture updated successfully!')),
        // );
        Get.snackbar("Profile", "Profile picture updated successfully!",
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      setState(() => _isUpdating = false);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to update profile picture: $e')),
      // );
      Get.snackbar("Profile", "Failed to update profile picture: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isUpdating = true);

        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception("No user is currently signed in.");

        if (_nameController.text.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'bio': _bioTextController.text.trim(),
            'name': _nameController.text.trim(),
            if (_profilePicUrl != null) 'profilePic': _profilePicUrl,
          });

          setState(() => _isUpdating = false);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Profile updated successfully!')),
          // );
          Get.snackbar("Profile", "Profile updated successfully!",
              colorText: Colors.white,
              backgroundColor: Colors.green,
              snackPosition: SnackPosition.BOTTOM);

          Navigator.pop(context);
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Username can't be empty")),
          // );
          Get.snackbar("Profile", "Username can't be empty",
              colorText: Colors.red);
        }
      } catch (e) {
        setState(() => _isUpdating = false);

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to update profile: $e')),
        // );
        Get.snackbar("Profile", "Failed to update profile: $e",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: Center(
          child: Text(
            "User not signed in.",
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.primary,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isUpdating ? null : _updateProfile,
            icon: _isUpdating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : const Icon(FlutterRemix.check_line),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load user details.",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No user details available.",
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          final Map<String, dynamic> userDetails =
              snapshot.data!.data() as Map<String, dynamic>;

          _bioTextController.text = _bioTextController.text.isEmpty
              ? userDetails['bio'] ?? ''
              : _bioTextController.text;

          _nameController.text = _nameController.text.isEmpty
              ? userDetails['name'] ?? ''
              : _nameController.text;

          _profilePicUrl ??= userDetails['profilePic'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple, clean profile picture
                  Center(
                    child: GestureDetector(
                      onTap: _isUpdating ? null : _selectProfilePicture,
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.surfaceVariant,
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _profilePicUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: _profilePicUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    FlutterRemix.user_3_fill,
                                    size: 60,
                                    color: colorScheme.primary.withOpacity(0.7),
                                  ),
                          ),
                          if (!_isUpdating)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.background,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  FlutterRemix.camera_line,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name field
                  Text(
                    "Name",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyTextfield(
                    editable: !_isUpdating,
                    hintText: "Add your name",
                    obscureText: false,
                    controller: _nameController,
                    focusNode: null,
                    textColor: colorScheme.onBackground,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 4) {
                        return 'minimum length should be 4';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Bio field
                  Text(
                    "Bio",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyTextfield(
                    editable: !_isUpdating,
                    hintText: "Write something about yourself...",
                    obscureText: false,
                    controller: _bioTextController,
                    focusNode: null,
                    textColor: colorScheme.onBackground,
                  ),

                  const SizedBox(height: 40),

                  // Simple save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
