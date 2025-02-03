import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../tickets/new_ticket_screen.dart';
import '../../../service/auth_service.dart';
import '../../../widgets/ticket_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tickets')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tickets found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var ticket = snapshot.data!.docs[index];
            return TicketCard(ticket: ticket);
          },
        );
      },
    );
  }
}