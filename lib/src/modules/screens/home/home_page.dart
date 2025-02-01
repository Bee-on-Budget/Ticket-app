import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticket_app/src/service/auth_service.dart';
import 'package:ticket_app/src/widgets/ticket_card.dart';

import '../tickets/new_ticket_screen.dart';

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

  // Widget _buildTicketItem(BuildContext context, DocumentSnapshot ticket) {
  //   final data = ticket.data() as Map<String, dynamic>;
  //   final createdDate = (data['createdDate'] as Timestamp).toDate();
  //   final status = data['status'] ?? '';
  //
  //   return Card(
  //     margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     child: ListTile(
  //       title: Text(data['title']),
  //       subtitle: Text(DateFormat.yMMMd().format(createdDate)),
  //       trailing: Chip(
  //         label: Text(
  //           _getStatusString(status),
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         backgroundColor: _getStatusColor(status),
  //       ),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => TicketDetailScreen(ticket: data),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // String _getStatusString(String status) {
  //   switch (status) {
  //     case 'Open':
  //     case 'In Progress':
  //     case 'Closed':
  //       return status;
  //     default:
  //       return 'Unknown';
  //   }
  // }

  // Color _getStatusColor(String status) {
  //   switch (status) {
  //     case 'Open':
  //       return Colors.green;
  //     case 'In Progress':
  //       return Colors.orange;
  //     case 'Closed':
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ticket_app/src/modules/screens/home_screen.dart';
//
// class HomePage extends StatelessWidget {
//   HomePage({super.key});
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<DocumentSnapshot> _getUserData(String uid) {
//     return FirebaseFirestore.instance.collection('users').doc(uid).get();
//   }
//
//   void _signOut(BuildContext context) async {
//     final navigator = Navigator.of(context);
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       await _auth.signOut();
//       navigator.pushReplacementNamed('/login');
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text('Error signing out: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = _auth.currentUser;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => _signOut(context),
//           ),
//         ],
//       ),
//       body: user == null
//           ? const Center(child: Text('No user signed in.'))
//           : FutureBuilder<DocumentSnapshot>(
//         future: _getUserData(user.uid),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text('User data not found.'));
//           }
//
//           // Safe way to get data from FireStore
//           var userData = snapshot.data!.data() as Map<String, dynamic>?;
//           if (userData == null) {
//             return Center(child: Text('No user data available.\n${user.uid}'));
//           }
//
//           // String fullName = userData['fullName'] ?? 'User';
//           // String role = userData['role'] ?? 'user';
//
//           return const HomeScreen();
//         },
//       ),
//     );
//   }
// }
