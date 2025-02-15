import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../config/enums/payment_methods.dart';
import '../../../service/synchronized_time.dart';
import '../../../widgets/form_field_outline.dart';
import '../../../widgets/submit_button.dart';
import '../../models/app_file.dart';

class NewTicketScreen extends StatefulWidget {
  const NewTicketScreen({super.key});

  @override
  State<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<NewTicketScreen> {
  late final GlobalKey<FormState> _formKey;
  String _description = "";
  String _title = "";
  PaymentMethods? _paymentMethod;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final FirebaseStorage _storage;
  static const _maxFiles = 10;
  static const _maxFileSizeMB = 5;
  static const _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

  final List<AppFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Ticket'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                FormFieldOutline(
                  label: "Title",
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Title can't be empty";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                ),
                FormFieldOutline(
                  label: "Description",
                  child: TextFormField(
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Field can't be empty";
                      }
                      if (value.length < 20) {
                        return "Description can't be less than 20";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                ),
                const Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8D8D8D),
                  ),
                ),
                DropdownButtonFormField<PaymentMethods>(
                  items: PaymentMethods.values
                      .map<DropdownMenuItem<PaymentMethods>>(
                        (element) => DropdownMenuItem(
                          value: element,
                          child: Text(element.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (paymentMethod) {
                    setState(() {
                      _paymentMethod = paymentMethod;
                    });
                  },
                  validator: (PaymentMethods? paymentMethod) {
                    if (paymentMethod == null) {
                      return "You need to select a payment method";
                    }
                    return null;
                  },
                ),
                _buildFileUploadSection(),
                const SizedBox(height: 10),
                SubmitButton(
                  onPressed: _isUploading ? null : _submitTicket,
                  buttonText: _isUploading ? 'Uploading...' : "Create",
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
            OutlinedButton.icon(
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
                        child: Text(file.name),
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: kIsWeb,
      );

      if (result != null) {
        final newFileCount = result.files.length;
        final totalFiles = _selectedFiles.length + newFileCount;

        if (totalFiles > _maxFiles) {
          _showErrorSnackBar("Maximum $_maxFiles files allowed");
          return;
        }

        final overSizedFiles = result.files
            .where((file) => file.size > _maxFileSizeBytes)
            .toList();

        if (overSizedFiles.isNotEmpty) {
          _showErrorSnackBar(
            "${overSizedFiles.length} file(s) exceed "
            "${_maxFileSizeBytes ~/ 1024 ~/ 1024}MB limits",
          );
          return;
        }

        setState(() {
          _selectedFiles.addAll(
            result.files.map((PlatformFile platformFile) {
              if (kIsWeb || platformFile.path == null) {
                return WebFile(
                  name: platformFile.name,
                  bytes: platformFile.bytes!,
                  size: platformFile.size,
                );
              }
              return LocalFile(
                name: platformFile.name,
                file: File(platformFile.path!),
                size: platformFile.size,
              );
            }).toList(),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error selecting files: ${e.toString()}");
    }
  }

  void _removeFile(AppFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isUploading = true);
    try {
      _formKey.currentState!.save();
      SynchronizedTime.initialize();
      final ticketRef = await _firestore.collection('tickets').add({
        'userId': user.uid,
        'title': _title,
        'description': _description,
        'paymentMethod': _paymentMethod!.toString(),
        'createdDate': SynchronizedTime.now(),
        'status': 'Open',
      });

      if (_selectedFiles.isNotEmpty) {
        final filesCollection = ticketRef.collection('files');

        for (final file in _selectedFiles) {
          final fileName = file.name;
          final storageRef = _storage.ref().child(
                'tickets/${ticketRef.id}/files/$fileName',
              );

          if (file is WebFile) {
            await storageRef.putData(file.bytes);
          } else if (file is LocalFile) {
            await storageRef.putFile(file.file);
          }

          final downloadUrl = await storageRef.getDownloadURL();

          SynchronizedTime.initialize();
          await filesCollection.add({
            'url': downloadUrl,
            'isThereMsgNotRead': false,
            'fileName': fileName,
            'uploadedAt': SynchronizedTime.now(),
            'userId': user.uid,
          });
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void init() {
    _formKey = GlobalKey<FormState>();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
  }
}
