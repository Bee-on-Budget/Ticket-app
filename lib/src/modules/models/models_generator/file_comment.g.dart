part of '../file_comment.dart';

FileComment _$FileCommentFromJson(Map<String, dynamic> json) =>
    FileComment(
      message: json['message'] ?? '',
      timeStamp: json['timestamp'] ?? SynchronizedTime.now(),
      isRead: json['isRead'] ?? false,
      senderId: json['senderId'] ?? '',
    );

Map<String, dynamic> _$FileCommentToJson(FileComment instance) =>
    <String, dynamic>{
      'message': instance.message,
      'timestamp': instance.timeStamp.toIso8601String(),
      'isRead': instance.isRead,
      'senderId': instance.senderId,
    };