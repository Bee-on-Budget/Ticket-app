import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessagingPage extends StatefulWidget {
  final String ticketId;

  const MessagingPage({super.key, required this.ticketId});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<File> _attachments = [];
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tickets')
                  .doc(widget.ticketId)
                  .collection('comments')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final comment = snapshot.data!.docs[index];
                    return _buildMessageItem(comment);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot comment) {
    final data = comment.data() as Map<String, dynamic>;
    final isCurrentUser = data['senderId'] == _auth.currentUser?.uid;
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final attachments = data['attachments'] as List<dynamic>? ?? [];

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              Text(
                'Support Agent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            if (data['message'] != null && data['message'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(data['message']),
              ),
            if (attachments.isNotEmpty)
              Column(
                children: attachments.map((url) => _buildAttachment(url)).toList(),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(String url) {
    final isImage = url.contains('.jpg') || url.contains('.png');
    final isPDF = url.contains('.pdf');

    return GestureDetector(
      onTap: () => _openAttachment(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isImage
            ? CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        )
            : ListTile(
          leading: Icon(
            isPDF ? Icons.picture_as_pdf : Icons.insert_drive_file,
            color: Colors.red,
          ),
          title: Text(
            url.split('/').last,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          if (_attachments.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final file = _attachments[index];
                  return Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        child: file.path.endsWith('.pdf')
                            ? const Icon(Icons.picture_as_pdf, size: 40)
                            : Image.file(file, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _attachments.removeAt(index)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickFiles,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _attachments = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _attachments.isEmpty) return;

    setState(() => _isSending = true);
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Upload attachments
      List<String> attachmentUrls = [];
      for (final file in _attachments) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final ref = _storage.ref().child('tickets/${widget.ticketId}/attachments/$fileName');

        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        attachmentUrls.add(url);
      }

      // Add message to Firestore
      await _firestore
          .collection('tickets')
          .doc(widget.ticketId)
          .collection('comments')
          .add({
        'message': _messageController.text,
        'senderId': user.uid,
        'timestamp': Timestamp.now(),
        'attachments': attachmentUrls,
      });

      // Clear inputs
      _messageController.clear();
      setState(() => _attachments.clear());
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: ${e.toString()}')),
      );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _openAttachment(String url) async {
    try {
      await OpenFilex.open(url);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open file: ${e.toString()}')),
      );
      }
    }
  }
}