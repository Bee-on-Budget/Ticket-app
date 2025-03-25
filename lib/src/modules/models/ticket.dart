import 'package:cloud_firestore/cloud_firestore.dart';

import 'ticket_file.dart';
import '../../config/enums/ticket_status.dart';

class Ticket {
  const Ticket({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.refId,
    required this.status,
    required this.publisher,
    required this.createdDate,
    this.files = const [],
  });

  final String ticketId;
  final String title;
  final String description;
  final String refId;
  final TicketStatus status;
  final String publisher;
  final DateTime createdDate;
  final List<TicketFile> files;

  Ticket copyWith({
    String? ticketId,
    String? title,
    String? description,
    String? refId,
    TicketStatus? status,
    String? publisher,
    DateTime? createdDate,
    List<TicketFile>? files,
  }) =>
      Ticket(
        ticketId: ticketId ?? this.ticketId,
        title: title ?? this.title,
        description: description ?? this.description,
        refId: refId ?? this.refId,
        status: status ?? this.status,
        publisher: publisher ?? this.publisher,
        createdDate: createdDate ?? this.createdDate,
        files: files ?? this.files,
      );

  factory Ticket.fromJson({
    required Map<String, dynamic> json,
    required String ticketId,
    List<TicketFile> files = const [],
    String? publisher,
  }) {
    // SynchronizedTime.initialize();
    return Ticket(
      ticketId: ticketId,
      title: json['title'] ?? "No Title",
      description: json['description'] ?? "No Description",
      refId: json['ref_id'] ?? 'No Reference Id',
      status: TicketStatus.fromString(json['status'] ?? "Unknown"),
      publisher: publisher ?? "Unknown Publisher",
      createdDate: (json['createdDate'] as Timestamp?)?.toDate() ??
          Timestamp.now().toDate(),
      files: files,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'title': title,
      'description': description,
      'ref_id': refId,
      'status': status.toString(),
      'publisher': publisher,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
