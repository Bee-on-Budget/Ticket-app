import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modules/models/ticket.dart';
import '../modules/screens/tickets/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticket: ticket),
              fullscreenDialog: true,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 6,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.status.getColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ticket.status.getColor(),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Ticket reference
              Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  Text(
                    ticket.ticketReference,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              // Description preview
              Text(
                ticket.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Footer with date
              Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(ticket.createdDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
