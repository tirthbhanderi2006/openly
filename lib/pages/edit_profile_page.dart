import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mithc_koko_chat_app/components/my_textfield.dart';
import 'package:mithc_koko_chat_app/services/storage_services.dart';

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

  // Select and upload a profile picture
  Future<void> _selectProfilePicture() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Show loading indicator while uploading
        setState(() => _isUpdating = true);

        // Upload image to Firebase Storage
        String downloadUrl = await StorageService().uploadImage(imageFile, 'profilePictures');

        // Update profile picture in Firestore
        final String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception("No user is currently signed in.");

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profilePic': downloadUrl,
        });

        setState(() {
          _profilePicUrl = downloadUrl;
          _isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  // Update bio and profile picture in Firestore
  Future<void> _updateProfile() async {
    try {
      setState(() => _isUpdating = true);

      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("No user is currently signed in.");

      if(_nameController.text.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
            {
              'bio': _bioTextController.text.trim(),
              'name': _nameController.text.trim(),
              if (_profilePicUrl != null) 'profilePic': _profilePicUrl,
            });

        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("username can't be empty")));
      }
    } catch (e) {
      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(
          child: Text(
            "User not signed in.",
            style: TextStyle(color: theme.error),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.primary,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isUpdating ? null : _updateProfile,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load user details.",
                style: TextStyle(color: theme.error),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No user details available.",
                style: TextStyle(color: theme.error),
              ),
            );
          }

          final Map<String, dynamic> userDetails = snapshot.data!.data() as Map<String, dynamic>;

          _bioTextController.text = _bioTextController.text.isEmpty
              ? userDetails['bio'] ?? ''
              : _bioTextController.text;

          _nameController.text = _nameController.text.isEmpty
              ? userDetails['name'] ?? ''
              : _nameController.text;

          _profilePicUrl ??= userDetails['profilePic'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isUpdating ? null : _selectProfilePicture,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: theme.secondary,
                        borderRadius: BorderRadius.circular(60),
                        image: _profilePicUrl != null
                            ? DecorationImage(
                          image: NetworkImage(_profilePicUrl!),
                          fit: BoxFit.cover,
                        )
                            : const DecorationImage(
                          image: NetworkImage('https://www.gravatar.com/avatar/?d=identicon'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _profilePicUrl == null
                          ? Icon(
                        Icons.person,
                        size: 72,
                        color: theme.primary,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Name",
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextfield(
                    hintText: "add your name",
                    obscureText: false,
                    controller: _nameController,
                    focusNode: null, textColor: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bio",
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyTextfield(
                    hintText: "Write something about yourself...",
                    obscureText: false,
                    controller: _bioTextController,
                    focusNode: null, textColor: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
