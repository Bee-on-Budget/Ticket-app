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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(ticket.title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text('Ticket Reference: ${ticket.ticketReference}'),
              Text(ticket.description,maxLines: 1,),
              Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(ticket.createdDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticketNoFile: ticket),
            ),
          );
        },
      ),
    );
  }
}