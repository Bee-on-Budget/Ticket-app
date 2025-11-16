import 'package:flutter/material.dart';
import 'package:ticket_app/src/modules/screens/auth/login/login_page.dart';

import '../../models/ticket_user.dart';
import '../tickets/new_ticket_screen.dart';
import '../../models/ticket.dart';
import '../../../service/data_service.dart';
import '../../../service/auth_service.dart';
import '../../../widgets/ticket_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<TicketUser>(
          stream: DataService.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Text("Ticket Details...");
            }
            final user = snapshot.data!;
            return Text('Welcome ${user.username}');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
            ),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: AuthService().isCurrentUser()
          ? Center(child: Text('User not logged in!'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by Ref ID or Ticket Reference...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Ticket>>(
                    stream: DataService.getUserTickets(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var tickets = snapshot.data!;
                      var filteredTickets = tickets.where((ticket) {
                        return ticket.refId.contains(searchQuery) ||
                            ticket.files.any(
                                (file) => file.refId.contains(searchQuery)) ||
                            ticket.ticketReference.contains(searchQuery);
                      }).toList();

                      if (filteredTickets.isEmpty) {
                        return Center(
                          child: Text('No matching tickets found.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredTickets.length,
                        itemBuilder: (context, index) {
                          var ticket = filteredTickets[index];
                          return TicketCard(ticket: ticket);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewTicketScreen(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
