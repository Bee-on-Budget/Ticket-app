import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ticket_app/src/config/enums/ticket_status.dart';

import '../modules/models/app_file.dart';
import '../modules/models/ticket.dart';
import '../modules/models/ticket_file.dart';
import '../modules/models/ticket_user.dart';

class DataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

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
        .asyncMap((snapshot) async {
      List<Ticket> tickets = [];
      for (var doc in snapshot.docs) {
        var filesSnapshot = await doc.reference.collection('files').get();
        List<TicketFile> files = filesSnapshot.docs.map((fileDoc) {
          return TicketFile.fromJson(
            json: fileDoc.data(),
            fileId: fileDoc.id,
          );
        }).toList();

        tickets.add(Ticket.fromJson(
          ticketId: doc.id,
          json: doc.data(),
          files: files,
        ));
      }
      return tickets;
    });
  }

  static Stream<List<TicketFile>> getTicketFiles(String ticketId) {
    return _firestore
        .collection('tickets')
        .doc(ticketId)
        .collection('files')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TicketFile.fromJson(json: doc.data(), fileId: doc.id);
      }).toList();
    });
  }

  static Future<List<String>> getTicketInfo() {
    final userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).get().then((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(jsonDecode(data['paymentMethods'] ?? ''));
    });
  }

  static Future<TicketFile> replaceOldFile({
    required String ticketId,
    required TicketFile oldFile,
    required AppFile newFile,
  }) async {
    try {
      // 1. Get file bytes based on platform
      final Uint8List fileBytes;

      if (newFile is LocalFile) {
        fileBytes = await newFile.file.readAsBytes();
      } else if (newFile is WebFile) {
        fileBytes = newFile.bytes;
      } else {
        throw Exception('Unsupported file type');
      }

      // 2. Upload new file to storage (overwrite existing)
      final storageRef = FirebaseStorage.instance.refFromURL(oldFile.url);
      await storageRef.putData(fileBytes);

      // 3. Get download URL for the new file
      final newDownloadUrl = await storageRef.getDownloadURL();

      // 4. Prepare updated file data
      final updatedFile = TicketFile(
        fileId: oldFile.fileId,
        fileName: newFile.name,
        refId: oldFile.refId,
        uploadedAt: Timestamp.now().toDate(),
        url: newDownloadUrl,
        isThereMsgNotRead: oldFile.isThereMsgNotRead,
      );

      // 5. Update Firestore document
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .collection('files')
          .doc(oldFile.fileId)
          .update(updatedFile.toJson());

      return updatedFile;
    } catch (e) {
      throw Exception('Failed to replace file: ${e.toString()}');
    }
  }
  static Future<void> postATicket({
    required String uid,
    required String title,
    required String description,
    required String paymentMethod,
    required List<AppFile> selectedFiles,
    required FirebaseStorage storage,
  }) async {
    final String ticketRefId = await generateUniqueId();
    final ticketRef = await _firestore.collection('tickets').add({
      'userId': uid,
      'title': title,
      'description': description,
      'ref_id': ticketRefId,
      'paymentMethod': paymentMethod,
      'createdDate': Timestamp.now(),
      'status': TicketStatus.open.toString(),
    });
    if (selectedFiles.isNotEmpty) {
      final filesCollection = ticketRef.collection('files');

      for (final file in selectedFiles) {
        final fileName = file.name;
        final storageRef = storage.ref().child(
              'tickets/${ticketRef.id}/files/$fileName',
            );

        if (file is WebFile) {
          await storageRef.putData(file.bytes);
        } else if (file is LocalFile) {
          await storageRef.putFile(file.file);
        }

        final downloadUrl = await storageRef.getDownloadURL();
        final String fileRefId = await generateUniqueId();
        await filesCollection.add({
          'url': downloadUrl,
          'isThereMsgNotRead': false,
          'ref_id': fileRefId,
          'fileName': fileName,
          'uploadedAt': Timestamp.now(),
          'userId': uid,
        });
      }
    }
  }

  static Future<String> getFileUrl(String url) async {
    return _firebaseStorage.refFromURL(url).getDownloadURL();
  }

  static Future<String> generateUniqueId() async {
    final counterRef = _firestore.collection('data').doc('preferences');

    try {
      final newId =
          await _firestore.runTransaction<String>((transaction) async {
        final doc = await transaction.get(counterRef);
        final String currentCount =
            ((int.tryParse(doc.data()?['idx_counter']) ?? 0) + 1)
                .toString()
                .padLeft(10, '0');
        transaction.update(counterRef, {'idx_counter': currentCount});
        return currentCount;
      });

      return newId;
    } catch (e) {
      return generateUniqueId();
    }
  }

  static Future<List<String>> getTitles() async {
    return _firestore.collection('data').doc('preferences').get().then((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final titles = data['titles'] as List<dynamic>?;
      return titles?.cast<String>() ?? [];
    });
  }

  static Future<List<String>> getUserPaymentMethods() {
    final userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).get().then((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final paymentMethods = data['paymentMethods'] as List<dynamic>?;
      return paymentMethods?.cast<String>() ?? [];
    });
  }

  static Future<void> changeFileUnreadMessage(
    String ticketId,
    String fileId,
  ) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .collection('files')
        .doc(fileId)
        .update(
      {'isThereMsgNotRead': false},
    );
  }
}
