import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../widgets/form_field_outline.dart';
import '../../../widgets/submit_button.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final FirebaseStorage _storage;

  static const _maxFiles = 10;
  static const _maxFileSizeMB = 5;
  static const _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

  final List<File> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Ticket')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 20,
              children: [
                FormFieldOutline(
                  controller: _titleController,
                  prefixIcon: Icons.title,
                  hintText: 'Title',
                ),
                FormFieldOutline(
                  controller: _descriptionController,
                  maxLines: 3,
                  prefixIcon: Icons.description,
                  hintText: 'Description',
                ),
                _buildFileUploadSection(),
                SubmitButton(
                  onPressed: _isUploading ? null : _submitTicket,
                  buttonText: _isUploading ? 'Uploading...' : 'Submit',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach Files'),
              onPressed: _isUploading ? null : _pickFiles,
            ),
            Text(
              '${_selectedFiles.length}/$_maxFiles files',
              style: TextStyle(
                color: _selectedFiles.length >= _maxFiles
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        if (_selectedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attached Files:'),
              const SizedBox(height: 8),
              ..._selectedFiles.map(
                (file) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(file.path.split('/').last),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeFile(file),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        final newFileCount = result.files.length;
        final totalFiles = _selectedFiles.length + newFileCount;

        if (totalFiles > _maxFiles) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Maximum $_maxFiles files allowed"),
              ),
            );
          }
          return;
        }

        final overSizedFiles = result.files
            .where((file) => file.size > _maxFileSizeBytes)
            .toList();

        if (overSizedFiles.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${overSizedFiles.length} file(s) exceed $_maxFileSizeBytes MB limits",
                ),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedFiles.addAll(
            result.paths
                .map(
                  (path) => File(path!),
                )
                .toList(),
          );
          // _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting files: ${e.toString()}')),
        );
      }
    }
  }

  void _removeFile(File file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isUploading = true);

    try {
      final ticketRef = await _firestore.collection('tickets').add({
        'userId': user.uid,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdDate': Timestamp.now(),
        'status': 'Open',
        'files': [],
      });

      if (_selectedFiles.isNotEmpty) {
        final List<String> fileUrls = [];
        for (final file in _selectedFiles) {
          final fileName = file.path.split('/').last;
          final storageRef =
              _storage.ref().child('tickets/${ticketRef.id}/files/$fileName');

          await storageRef.putFile(file);
          final downloadUrl = await storageRef.getDownloadURL();
          fileUrls.add(downloadUrl);
        }

        await ticketRef.update({'files': fileUrls});
      }

      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void init() {
    _formKey = GlobalKey<FormState>();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
  }

  void finish() {
    _titleController.dispose();
    _descriptionController.dispose();
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../widgets/form_field_outline.dart';
// import '../../widgets/submit_button.dart';
//
// class NewTicketScreen extends StatefulWidget {
//   const NewTicketScreen({super.key});
//
//   @override
//   State<NewTicketScreen> createState() => _NewTicketScreenState();
// }
//
// class _NewTicketScreenState extends State<NewTicketScreen> {
//   late final GlobalKey<FormState> _formKey;
//   late final TextEditingController _titleController;
//   late final TextEditingController _descriptionController;
//   late final FirebaseFirestore _firestore;
//   late final FirebaseAuth _auth;
//
//   // String _status = 'Open';
//
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }
//
//   @override
//   void dispose() {
//     finish();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('New Ticket')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               spacing: 20,
//               children: [
//                 FormFieldOutline(
//                   controller: _titleController,
//                   prefixIcon: Icons.title,
//                   hintText: 'Title',
//                 ),
//                 FormFieldOutline(
//                   controller: _descriptionController,
//                   maxLines: 3,
//                   prefixIcon: Icons.description,
//                   hintText: 'Description',
//                 ),
//                 SubmitButton(
//                   onPressed: _submitTicket,
//                   buttonText: 'Submit',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _submitTicket() async {
//     final navigator = Navigator.of(context);
//     if (_formKey.currentState!.validate()) {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       await _firestore.collection('tickets').add({
//         'userId': user.uid,
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         // 'status': _status,
//         'createdDate': Timestamp.now(),
//       });
//
//       navigator.pop();
//     }
//   }
//
//   void init() {
//     _formKey = GlobalKey<FormState>();
//     _titleController = TextEditingController();
//     _descriptionController = TextEditingController();
//
//     _firestore = FirebaseFirestore.instance;
//     _auth = FirebaseAuth.instance;
//   }
//
//   void finish(){
//     _titleController.dispose();
//     _descriptionController.dispose();
//   }
// }
