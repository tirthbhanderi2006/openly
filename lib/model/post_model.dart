import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mithc_koko_chat_app/model/comments_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String userName;
  final String caption;
  final String imgUrl;
  final DateTime timeStamp;
  final List<String> likes;
  final List<CommentsModel> comments;
  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.caption,
    required this.imgUrl,
    required this.timeStamp,
    required this.likes,
    required this.comments
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'caption': caption,
      'imgUrl': imgUrl,
      'timeStamp': Timestamp.fromDate(timeStamp),
      'likes': likes,
      'comments':comments.map((comments) => comments.toJson(),).toList()
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse the timestamp field
    final timeStampField = json['timeStamp'];
    DateTime parsedTimeStamp;

    if (timeStampField is Timestamp) {
      parsedTimeStamp = timeStampField.toDate();
    } else if (timeStampField is String) {
      parsedTimeStamp = DateTime.parse(timeStampField);
    } else if (timeStampField is DateTime) {
      parsedTimeStamp = timeStampField;
    } else {
      throw Exception('Invalid type for timeStamp field: ${timeStampField.runtimeType}');
    }

    // Parse the likes field
    List<String> parsedLikes = [];
    if (json['likes'] != null && json['likes'] is List) {
      parsedLikes = List<String>.from(json['likes'] as List<dynamic>);
    }
    List<CommentsModel> comments=(json['comments'] as List<dynamic>?)?.map((commentJson) => CommentsModel.fromJson(commentJson),).toList() ?? [];

    return PostModel(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      caption: json['caption'] ?? '',
      imgUrl: json['imgUrl'] ?? '',
      timeStamp: parsedTimeStamp,
      likes: parsedLikes,
      comments: comments
    );
  }
}
