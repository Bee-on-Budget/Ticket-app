import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'file_messaging_page.dart';
import '../../models/ticket.dart';
import '../../models/ticket_file.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ticket.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Status:', ticket.status.toString()),
            _buildDetailItem(
              "Created: ",
              DateFormat.yMMMd().add_Hms().format(ticket.createdDate),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(ticket.description),
            const SizedBox(height: 16),
            const Text(
              'Attachments:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildFileList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList() {
    final List<TicketFile> files = ticket.files;
    if (files.isEmpty) {
      return const Center(child: Text('No attachments'));
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final fileName = file.fileName;
        final isImage = fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg') ||
            fileName.toLowerCase().endsWith('.png');
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: isImage
                ? CachedNetworkImage(
                    imageUrl: file.url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error_outline),
                  )
                : const SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.picture_as_pdf_outlined,
                    ),
                  ),
            title: Text(fileName),
            trailing: file.isThereMsgNotRead
                ? Icon(
                    Icons.notification_important_outlined,
                    color: Theme.of(context).colorScheme.error,
                  )
                : const SizedBox(),
            onTap: () async {
              await FirebaseFirestore.instance
                  .collection('tickets')
                  .doc(ticket.ticketId)
                  .collection('files')
                  .doc(file.fileId)
                  .update({
                'isThereMsgNotRead': false,
              });
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FileMessagingPage(
                      ticketId: ticket.ticketId,
                      file: file,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
