import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String? imageUrl; // Optional field for image URLs
  final Timestamp timestamp;

  MessageModel({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.timestamp,
  });

  // Convert MessageModel to Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl, // Include imageUrl in the map
      'timestamp': timestamp,
    };
  }

  // Create MessageModel from Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'], // Extract imageUrl if available
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
