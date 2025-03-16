import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modules/models/ticket.dart';
import '../modules/models/ticket_file.dart';
import '../modules/models/ticket_user.dart';

class DataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<TicketUser> getCurrentUser() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return TicketUser.fromJson(snapshot.docs.first.data());
    });
  }

  static Stream<List<Ticket>> getUserTickets() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Ticket.fromJson(
          ticketId: doc.id,
          json: doc.data(),
        );
      }).toList();
    });
  }

  static Stream<Ticket> getTicketWithFiles(Ticket ticket) {
    List<TicketFile> files = [];
    return _firestore
        .collection('tickets')
        .doc(ticket.ticketId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      files.addAll(
        snapshot.docs.map(
          (doc) => TicketFile.fromJson(json: doc.data(), fileId: doc.id),
        ),
      );
      return ticket.copyWith(files: files);
    });
  }

  static Future<List<String>> getTicketInfo() {
    final userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).get().then((doc){
      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(jsonDecode(data['paymentMethods'] ?? ''));
    });
    // return _firestore.collection('users').doc(userId).snapshots().;
  }
}























