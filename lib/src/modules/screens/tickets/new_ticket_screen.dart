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
  final Map<String, dynamic> _customFieldValues = {};
  Map<String, dynamic> _availableCustomFields = {};
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
                            isExpanded: true,
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
                                _customFieldValues.clear();
                                _availableCustomFields.clear();
                              });

                              try {
                                final List<String> paymentMethods =
                                    await DataService.getCompanyPaymentMethods(
                                  company,
                                );
                                final Map<String, dynamic> customFields =
                                    await DataService.getCompanyCustomFields(
                                  company,
                                );

                                setState(() {
                                  _paymentMethods.addAll(paymentMethods);
                                  _availableCustomFields = customFields;
                                  // Initialize custom field values
                                  customFields.forEach((key, value) {
                                    if (value is List && value.isNotEmpty) {
                                      _customFieldValues[key] = value.first;
                                    }
                                  });
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
                        isExpanded: true,
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
                    // Custom Fields
                    if (_availableCustomFields.isNotEmpty)
                      ..._availableCustomFields.entries.map((entry) {
                        final fieldName = entry.key;
                        final fieldValues = entry.value;
                        final valueList =
                            fieldValues is List ? fieldValues : [fieldValues];

                        return FormFieldOutline(
                          label: fieldName,
                          child: DropdownButtonFormField<String>(
                            value: _customFieldValues[fieldName],
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text('Select $fieldName (Optional)'),
                              ),
                              ...valueList
                                  .map<DropdownMenuItem<String>>(
                                    (value) => DropdownMenuItem(
                                      value: value.toString(),
                                      child: Text(
                                        value.toString(),
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                if (value == null) {
                                  _customFieldValues.remove(fieldName);
                                } else {
                                  _customFieldValues[fieldName] = value;
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    FormFieldOutline(
                      label: 'Attachments',
                      isRequired: true,
                      child: FileListView(
                        maxFiles: _maxFiles,
                        selectedFiles: _selectedFiles,
                        isError: _attachmentError,
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
        customFields: _customFieldValues,
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

  void init() async {
    _formKey = GlobalKey<FormState>();
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;

    final companies = await DataService.getUserCompanies();

    if (companies.isNotEmpty) {
      final paymentMethods = await DataService.getCompanyPaymentMethods(
        companies.first,
      );
      final customFields = await DataService.getCompanyCustomFields(
        companies.first,
      );

      setState(() {
        _company = companies.first;
        _paymentMethods.clear();
        _paymentMethods.addAll(paymentMethods);
        if (paymentMethods.isNotEmpty) {
          _paymentMethod = paymentMethods.first;
        }
        _availableCustomFields = customFields;
        // Initialize custom field values
        customFields.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            _customFieldValues[key] = value.first;
          }
        });
      });
    }
  }
}
