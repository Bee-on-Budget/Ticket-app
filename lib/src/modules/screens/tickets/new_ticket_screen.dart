import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import '../../../config/enums/payment_methods.dart';
import '../../../service/data_service.dart';
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
  String? _title;
  // PaymentMethods? _paymentMethod;
  String? _paymentMethod;
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
              spacing: 15,
              children: [
                FutureBuilder(
                  future: DataService.getTitles(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showErrorSnackBar('Error while loading the titles');
                      });
                    }
                    final List<String> titles = [];
                    if (snapshot.hasData) {
                      titles.addAll(snapshot.data!);
                    }
                    return FormFieldOutline(
                      label: 'Title',
                      isRequired: true,
                      child: DropdownButtonFormField<String>(
                        value: _title,
                        decoration: InputDecoration(),
                        isExpanded: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "You need to select a title";
                          }
                          return null;
                        },
                        items: titles
                            .map(
                              (title) => DropdownMenuItem<String>(
                                value: title,
                                child: Text(
                                  title,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (title) {
                          setState(() {
                            _title = title!;
                          });
                        },
                        onSaved: (title) {
                          _title = title;
                        },
                      ),
                    );
                  },
                ),
                FormFieldOutline(
                  label: "Description",
                  child: TextFormField(
                    maxLines: 6,
                    onSaved: (value) {
                      if(value == null || value.trim().isEmpty) {
                        _description = 'No Description';
                        return;
                      }
                      _description = value.trim();
                    },
                  ),
                ),
                FutureBuilder<List<String>>(
                  future: DataService.getUserPaymentMethods(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showErrorSnackBar('Error while loading the Payment Methods');
                      });
                    }
                    final List<String> paymentMethods = [];
                    if (snapshot.hasData) {
                      paymentMethods.addAll(snapshot.data!);
                    }
                    return FormFieldOutline(
                      label: 'Payment Method',
                      isRequired: true,
                      child: DropdownButtonFormField<String>(
                        items: paymentMethods
                            .map<DropdownMenuItem<String>>(
                              (paymentMethod) => DropdownMenuItem(
                            value: paymentMethod,
                            child: Text(
                              paymentMethod,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (paymentMethod) {
                          setState(() {
                            _paymentMethod = paymentMethod;
                          });
                        },
                        validator: (String? paymentMethod) {
                          if (paymentMethod == null) {
                            return "You need to select a payment method";
                          }
                          return null;
                        },
                      ),
                      // child: DropdownButtonFormField<PaymentMethods>(
                      //   items: PaymentMethods.values
                      //       .map<DropdownMenuItem<PaymentMethods>>(
                      //         (element) => DropdownMenuItem(
                      //           value: element,
                      //           child: Text(
                      //             element.toString(),
                      //             style: Theme.of(context).textTheme.bodyLarge,
                      //           ),
                      //         ),
                      //       )
                      //       .toList(),
                      //   onChanged: (paymentMethod) {
                      //     setState(() {
                      //       _paymentMethod = paymentMethod;
                      //     });
                      //   },
                      //   validator: (PaymentMethods? paymentMethod) {
                      //     if (paymentMethod == null) {
                      //       return "You need to select a payment method";
                      //     }
                      //     return null;
                      //   },
                      // ),
                    );
                  }
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
      await DataService.postATicket(
        uid: user.uid,
        title: _title!,
        description: _description,
        paymentMethod: _paymentMethod!,
        selectedFiles: _selectedFiles,
        storage: _storage,
      );
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
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
  }
}
