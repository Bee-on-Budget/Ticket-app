// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class MessagingPage extends StatefulWidget {
//   final String ticketId;
//   final String? fileId;
//
//   const MessagingPage({
//     super.key,
//     required this.ticketId,
//     this.fileId,
//   });
//
//   @override
//   State<MessagingPage> createState() => _MessagingPageState();
// }
//
// class _MessagingPageState extends State<MessagingPage> {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//   final _messageController = TextEditingController();
//   final _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.fileId != null ? 'File Discussion' : 'Ticket Conversation'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _getMessageStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollController.jumpTo(
//                     _scrollController.position.maxScrollExtent,
//                   );
//                 });
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(8),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final message = snapshot.data!.docs[index];
//                     return _buildMessageItem(message);
//                   },
//                 );
//               },
//             ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }
//
//   Stream<QuerySnapshot<Map<String, dynamic>>> _getMessageStream() {
//     final baseQuery = _firestore
//         .collection('tickets')
//         .doc(widget.ticketId);
//
//     if (widget.fileId != null) {
//       return baseQuery
//           .collection('files')
//           .doc(widget.fileId)
//           .collection('comments')
//           .orderBy('timestamp', descending: false)
//           .snapshots();
//     }
//
//     return baseQuery
//         .collection('comments')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }
//
//   Widget _buildMessageItem(DocumentSnapshot message) {
//     final data = message.data() as Map<String, dynamic>;
//     final isCurrentUser = data['senderId'] == _auth.currentUser?.uid;
//     final timestamp = (data['timestamp'] as Timestamp).toDate();
//
//     return Align(
//       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 300),
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isCurrentUser
//               ? Theme.of(context).colorScheme.primaryContainer
//               : Theme.of(context).colorScheme.surfaceContainerHighest,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isCurrentUser)
//               Text(
//                 'Support',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//               ),
//             Text(data['message']),
//             const SizedBox(height: 4),
//             Text(
//               DateFormat('HH:mm').format(timestamp),
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).colorScheme.outline,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: Colors.grey.shade300)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 hintText: 'Type your message...',
//                 border: InputBorder.none,
//               ),
//               maxLines: 3,
//               minLines: 1,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: _sendMessage,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.isEmpty) return;
//
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     try {
//       final collectionRef = widget.fileId != null
//           ? _firestore
//           .collection('tickets')
//           .doc(widget.ticketId)
//           .collection('files')
//           .doc(widget.fileId)
//           .collection('comments')
//           : _firestore
//           .collection('tickets')
//           .doc(widget.ticketId)
//           .collection('comments');
//
//       await collectionRef.add({
//         'message': _messageController.text,
//         'senderId': user.uid,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       _messageController.clear();
//     } catch (e) {
//       if(mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error sending message: ${e.toString()}')),
//       );
//       }
//     }
//   }
// }