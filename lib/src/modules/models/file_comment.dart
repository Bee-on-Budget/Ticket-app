import 'package:json_annotation/json_annotation.dart';
import 'package:ticket_app/src/service/synchronized_time.dart';

part './models_generator/file_comment.g.dart';

@JsonSerializable()
class FileComment {
  FileComment({
    required this.message,
    required this.timeStamp,
    required this.isRead,
    required this.senderId,
  });

  final String message;
  final DateTime timeStamp;
  final String senderId;
  final bool isRead;

  factory FileComment.fromJson(Map<String, dynamic> json) =>
      _$FileCommentFromJson(json);

  Map<String, dynamic> toJson() => _$FileCommentToJson(this);

  @override
  String toString() {
    return 'FileComment{'
        '\n\tmessage: $message,'
        '\n\tisRead: $isRead,'
        '\n\ttimeStamp: $timeStamp,'
        '\n\tsenderId: $senderId}';
  }
}
