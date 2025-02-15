import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticket_app/src/service/data_service.dart';

import '../modules/models/ticket.dart';
import '../modules/screens/tickets/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          ticket.title,
          maxLines: 2,
        ),
        subtitle: Text(DateFormat.yMMMd().format(ticket.createdDate)),
        leading: SizedBox(
          width: 66,
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
                    color: ticket.status.getColor(),
                  ),
                ),
              ),
              Text(
                ticket.status.toString(),
                style: TextStyle(
                  color: ticket.status.getColor(),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StreamBuilder<Ticket>(
                    stream: DataService.getTicketWithFiles(ticket),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error loading files: ${snapshot
                                .error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final newTicket = snapshot.data;
                      return TicketDetailScreen(ticket: newTicket!);
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}