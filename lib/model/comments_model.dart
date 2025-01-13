import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel{
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timeStamp;

  CommentsModel({
      required this.id,
      required this.postId,
      required this.userId,
      required this.userName,
      required this.text,
      required this.timeStamp
  });

  Map<String,dynamic> toJson(){
    return{
      'id':id,
      'postId':postId,
      'userId':userId,
      'userName':userName,
      'text':text,
      'timeStamp':Timestamp.fromDate(timeStamp)
    };
  }

  factory CommentsModel.fromJson(Map<String,dynamic> json){
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
    return CommentsModel(
        id: json['id'],
        postId: json['postId'],
        userId:json ['userId'],
        userName: json['userName'],
        text: json['text'],
        timeStamp: parsedTimeStamp
    );
  }
}