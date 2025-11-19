import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../service/data_service.dart';
import '../../../service/functions.dart';
import '../../../widgets/file_list_view.dart';
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
  String? _paymentMethod;
  String? _company;
  final List<String> _paymentMethods = [];
  late final FirebaseAuth _auth;
  late final FirebaseStorage _storage;
  static const _maxFiles = 10;
  bool _attachmentError = false;

  final List<AppFile> _selectedFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Ticket'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                            showErrorSnackBar(
                              context,
                              'Error while loading the titles',
                            );
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
                                      style: theme.textTheme.bodyLarge,
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
                          if (value == null || value.trim().isEmpty) {
                            _description = 'No Description';
                            return;
                          }
                          _description = value.trim();
                        },
                      ),
                    ),
                    FutureBuilder<List<String>>(
                      future: DataService.getUserCompanies(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showErrorSnackBar(
                              context,
                              'Error while loading the Company',
                            );
                          });
                        }
                        final List<String> companies = [];
                        if (snapshot.hasData) {
                          companies.addAll(snapshot.data!);
                        }
                        if (companies.isNotEmpty) {
                          _company = companies.first;
                        }
                        return FormFieldOutline(
                          label: 'Company',
                          isRequired: true,
                          child: DropdownButtonFormField<String>(
                            value: _company,
                            items: companies
                                .map<DropdownMenuItem<String>>(
                                  (company) => DropdownMenuItem(
                                    value: company,
                                    child: Text(
                                      company,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (company) async {
                              if (company == null) return;
                              setState(() {
                                _company = company;
                                _paymentMethods.clear();
                                _paymentMethod = null;
                              });

                              try {
                                final List<String> paymentMethods =
                                    await DataService.getCompanyPaymentMethods(
                                  company,
                                );

                                setState(() {
                                  _paymentMethods.addAll(paymentMethods);
                                });
                              } catch (e) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showErrorSnackBar(
                                    context,
                                    'Error while loading the Payment Methods',
                                  );
                                });
                              }
                            },
                            validator: (String? company) {
                              if (company == null) {
                                return "You need to select a company";
                              }
                              return null;
                            },
                          ),
                        );
                      },
                    ),
                    FormFieldOutline(
                      label: 'Payment Method',
                      isRequired: true,
                      child: DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        items: _paymentMethods
                            .map<DropdownMenuItem<String>>(
                              (paymentMethod) => DropdownMenuItem(
                                value: paymentMethod,
                                child: Text(
                                  paymentMethod,
                                  style: theme.textTheme.bodyLarge,
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
                    ),
                    FormFieldOutline(
                      label: 'Attachments',
                      isRequired: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FileListView(
                            maxFiles: _maxFiles,
                            selectedFiles: _selectedFiles,
                          ),
                          if (_attachmentError)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                top: 4,
                              ),
                              child: Text(
                                "Attachment are required",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SubmitButton(
                      onPressed: _submitTicket,
                      buttonText: "Create",
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  bool _validate() {
    bool validateStatus = true;
    if (!_formKey.currentState!.validate()) validateStatus = false;

    if (_selectedFiles.isEmpty) {
      setState(() {
        _attachmentError = true;
      });
      validateStatus = false;
    } else if (_attachmentError) {
      setState(() {
        _attachmentError = false;
      });
    }
    return validateStatus;
  }

  Future<void> _submitTicket() async {
    if (!_validate()) return;
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
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error: ${e.toString()}');
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
