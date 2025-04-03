import 'package:cloud_firestore/cloud_firestore.dart';

class TicketFile {
  const TicketFile({
    required this.fileId,
    required this.fileName,
    required this.refId,
    required this.uploadedAt,
    required this.url,
    required this.isThereMsgNotRead,
  });

  final String fileId;
  final String fileName;
  final String refId;
  final DateTime? uploadedAt;
  final String url;
  final bool isThereMsgNotRead;

  factory TicketFile.fromJson({
    required Map<String, dynamic> json,
    required String fileId,
  }) {
    return TicketFile(
      fileId: fileId,
      fileName: json['fileName'] ?? 'No Filename',
      refId: json['ref_id'] ?? 'No Reference Id',
      uploadedAt: (json['uploadedAt'] as Timestamp?)?.toDate(),
      url: json['url'] ?? 'Missing url',
      isThereMsgNotRead: json['isThereMsgNotRead']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'uploadedAt': uploadedAt,
      'ref_id': refId,
      'url': url,
      'isThereMsgNotRead': isThereMsgNotRead,
    };
  }
}
