import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String senderEmail;
  final String? receiverId; // Nullable for group messages
  final String? groupId; // Nullable for one-to-one chats
  final String message;
  final String? imageUrl; // Optional field for image messages
  final Timestamp timestamp;

  MessageModel({
    required this.senderId,
    required this.senderEmail,
    this.receiverId, // Set null if it's a group message
    this.groupId, // Set null if it's a one-to-one message
    required this.message,
    this.imageUrl,
    required this.timestamp,
  });

  // 🔹 Convert `MessageModel` to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId, // Null for group messages
      'groupId': groupId, // Null for one-to-one messages
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  // 🔹 Create `MessageModel` from Firestore Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverId: map['receiverId'], // Can be null for group chats
      groupId: map['groupId'], // Can be null for one-to-one chats
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
