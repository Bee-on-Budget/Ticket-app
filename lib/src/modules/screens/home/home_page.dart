import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../tickets/new_ticket_screen.dart';
import '../../models/ticket.dart';
import '../../../service/data_service.dart';
import '../../../service/auth_service.dart';
import '../../../widgets/ticket_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: const Color(0xFF3D4B3F),
            ),
            onPressed: () async {
              await _authService.logout();
              navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTicketScreen()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: _buildTicketsList(),
    );
  }

  Widget _buildTicketsList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Center(child: Text('User not logged in!'));
    }

    return StreamBuilder<List<Ticket>>(
      stream: DataService.getUserTickets(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.isEmpty) {
          return Center(child: Text('No tickets found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var ticket = snapshot.data![index];
            return TicketCard(ticket: ticket);
          },
        );
      },
    );
  }
}