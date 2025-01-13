import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String name;
  String profilePic;
  String bio;
  List<String> followers;
  List<String> following;
  String fcmToken;
  Timestamp createdAt;

  // Constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.profilePic,
    required this.bio,
    required this.followers,
    required this.following,
    required this.fcmToken,
    required this.createdAt,
  });

  // Convert UserModel to Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'bio': bio,
      'followers': followers,
      'following': following,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
    };
  }

  // Convert Map to UserModel (for reading from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'],
      bio: map['bio'] ?? '',
      followers: List<String>.from(map['followers'] ?? []), // Handle missing followers as an empty list
      following: List<String>.from(map['following'] ?? []), // Handle missing following as an empty list
      fcmToken: map['fcmToken'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
