import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../service/data_service.dart';

import '../../../widgets/attachment_card.dart';
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
      appBar: AppBar(title: const Text("Ticket details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 10,
          left: 30,
          right: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            // Title
            Text(
              ticket.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Ticket Reference & Reference Id
            Text(
              'TicketRef-${ticket.ticketReference} • ${ticket.refId}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            // Creation Date & Ticket Status
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      // DateFormat('MMM dd, yyyy')
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(ticket.createdDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ticket.status.getColor().withValues(alpha: 0.1),
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
            const SizedBox(height: 16),
            // Description
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ticket.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            // Attachments
            Text(
              'Attachments (${ticket.files.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            StreamBuilder<List<TicketFile>>(
              stream: DataService.getTicketFiles(ticket.ticketId),
              initialData: [],
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading files: ${snapshot.error}',
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final files = snapshot.data!;
                if (files.isEmpty) {
                  return const Text('No attachments');
                }
                return Column(
                  spacing: 8,
                  children: [
                    ...files.map(
                      (file) => AttachmentCard(
                        file: file,
                        ticket: ticket,
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
