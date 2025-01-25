import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final createdDate = (ticket['createdDate'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(title: Text(ticket['title'])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${ticket['status']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Created: ${DateFormat.yMMMd().add_Hms().format(createdDate)}'),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(ticket['description'] ?? 'No description'),
          ],
        ),
      ),
    );
  }
}