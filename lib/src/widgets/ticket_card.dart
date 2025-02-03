import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modules/screens/tickets/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  TicketCard({super.key, required DocumentSnapshot ticket}) {
    data = ticket.data() as Map<String, dynamic>;
    data['ticketId'] = ticket.id;
    createdDate = (data['createdDate'] as Timestamp).toDate();
    status = data['status'] ?? '';
    title = data['title'] ?? '';
  }

  late final Map<String, dynamic> data;
  late final String title;
  late final DateTime createdDate;
  late final String status;
  late final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          title,
          maxLines: 2,
        ),
        subtitle: Text(DateFormat.yMMMd().format(createdDate)),
        leading: SizedBox(
          width: 65,
          child: Row(
            spacing: 5,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .doc(data['ticketId'])
                    .collection('files')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading files: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Combine ticket data with files from subcollection
                  final mergedData = Map<String, dynamic>.from(data);
                  mergedData['files'] = snapshot.data!.docs.map((doc) {
                    final fileData = doc.data() as Map<String, dynamic>;
                    return {
                      'fileId': doc.id,
                      ...fileData,
                    };
                  }).toList();
                  // mergedData['id'] = data;

                  return TicketDetailScreen(ticket: mergedData);
                },
              ),
              // builder: (context) => StreamBuilder<QuerySnapshot>(
              //     stream: FirebaseFirestore.instance
              //         .collection('tickets')
              //         .doc(data['ticketId'])
              //         .collection('files')
              //         .snapshots(),
              //     builder: (context, snapshot) {
              //
              //       return TicketDetailScreen(ticket: data);
              //     }),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Open':
        return 'Opened';
      // return '⦿ Opened';
      case 'In Progress':
        return 'Ongoing';
      // return '◉ Ongoing';
      case 'Closed':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }
}
