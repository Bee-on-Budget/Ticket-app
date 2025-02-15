import 'package:cloud_firestore/cloud_firestore.dart';

import 'attached_file.dart';

enum TicketStatus {
  open,
  inProgress,
  closed,
  unknown,
}

class Ticket {
  Ticket(DocumentSnapshot ticketData) {
    Map<String, dynamic> data = ticketData.data() as Map<String, dynamic>;
    ticketId = ticketData.id;
    ticketName = data['ticket-title'] ?? '';
    description = data['description'] ?? '';
    status = data['status'] ?? '';
  }

  late final String ticketId;
  late final String ticketName;
  late final String description;
  late final TicketStatus status;
  late final List<AttachedFile> files;
  late final DateTime createdTime;

  // Ticket fromJson(DocumentSnapshot ticketData) {
  //   Map<String, dynamic> data;
  //   return Ticket(
  //       ticketName: data['ticket-title'] ?? '',
  //       createdTime: (data['createdDate'] as Timestamp).toDate(),
  //       files: List.,
  //       description: data['description']);
  // }
}
