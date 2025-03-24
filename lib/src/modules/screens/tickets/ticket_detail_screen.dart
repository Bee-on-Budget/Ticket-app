import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ticket_app/src/service/data_service.dart';

import 'file_messaging_page.dart';
import '../../models/ticket.dart';
import '../../models/ticket_file.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketNoFile,
  });

  final Ticket ticketNoFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ticket details")),
      body: StreamBuilder<Ticket>(
          stream: DataService.getTicketWithFiles(ticketNoFile),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading files: ${snapshot.error}',
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ticket = snapshot.data!;
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ticket.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      // Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(ticket.createdDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(), // Adds space between date and status
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              ticket.status.getColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.status.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ticket.status.getColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Attachments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: _buildFileList(ticket),
                  ),
                ],
              ),
            );
          }),
    );
  }
  
  Widget _buildFileList(Ticket ticket) {
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
            subtitle: Text('Attache Id: ${file.refId}'),
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
                Navigator.pushReplacement(
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
