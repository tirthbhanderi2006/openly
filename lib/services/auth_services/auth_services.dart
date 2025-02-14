import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/pages/auth/login_or_register.dart';
import 'package:mithc_koko_chat_app/model/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In
  Future<void> signIn({required String email, required String password}) async {
    try {
      // Perform login with Firebase Authentication
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;
      // Get the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        // Save the FCM token to Firestore under the user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String profilePic,
  }) async {
    final String defaultName = email.split('@')[0];
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Add user details to Firestore
      await _firestore.collection("users").doc(credential.user!.uid).set(
          UserModel(
                  uid: credential.user!.uid,
                  email: email,
                  name: defaultName,
                  profilePic: 'https://www.gravatar.com/avatar/?d=identicon',
                  bio: '',
                  followers: [],
                  following: [],
                  fcmToken: await _getFCMToken().toString(),
                  createdAt: Timestamp.now())
              .toMap());
      // await _firestore.collection('users').doc(credential.user!.uid).set({
      //   'uid': credential.user!.uid,
      //   'email': email,
      //   'name': defaultName,
      //   'profilePic': 'https://www.gravatar.com/avatar/?d=identicon',
      //   'bio':'',
      //   'fcmToken':await _getFCMToken(),
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<String?> _getFCMToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    // print("FCM Token: $token");
    return token;
  }

  // Sign Out
  Future<void> logout(context) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      Get.offAll(() => LoginOrRegister());
      Get.snackbar('Logout', 'Logout Successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Error signing out: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

//   get current user details
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      // Get the current user's UID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("No user is currently signed in.");
      }
      // Reference to the user's document in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(
              'users') // Replace 'users' with your Firestore collection name
          .doc(userId)
          .get();
      // Check if the document exists
      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }
      // Return the user's data as a map
      // print(userDoc.data()as Map<String, dynamic>);
      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      // Handle errors and print to console
      // print("Error fetching user details: $e");
      return null;
    }
  }
}
