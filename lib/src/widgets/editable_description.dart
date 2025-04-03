import 'package:flutter/material.dart';
import 'package:ticket_app/src/config/enums/ticket_status.dart';
import 'package:ticket_app/src/service/functions.dart';

import '../modules/models/ticket.dart';
import '../service/data_service.dart';

class EditableDescription extends StatefulWidget {
  const EditableDescription({
    super.key,
    required this.ticket,
  });

  final Ticket ticket;

  @override
  State<EditableDescription> createState() => _EditableDescriptionState();
}

class _EditableDescriptionState extends State<EditableDescription> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final String _initialDescription;
  late final String _ticketId;
  late final TicketStatus _ticketStatus;
  String _oldValue = '';
  bool _isEditing = false;
  bool _isSaving = false;
  bool _validate = false;

  @override
  void initState() {
    super.initState();
    _ticketId = widget.ticket.ticketId;
    _initialDescription = widget.ticket.description;
    _ticketStatus = widget.ticket.status;
    _controller = TextEditingController(text: _initialDescription);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: !_isEditing,
              style: theme.textTheme.bodyMedium,
              autocorrect: true,
              cursorColor: theme.colorScheme.primary,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                filled: false,
                isDense: true,
                enabled: !_isSaving,
                errorText: _validate ? "Value Can't Be Empty" : null,
                border: _isEditing ? null : InputBorder.none,
                enabledBorder: _isEditing
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      )
                    : InputBorder.none,
                errorBorder: _isEditing
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                          width: 2,
                        ),
                      )
                    : InputBorder.none,
                contentPadding: const EdgeInsets.all(10),
                hintText: 'Tap to add description',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              onChanged: (value) {
                if (_validate && value.isNotEmpty) {
                  setState(() => _validate = false);
                }
              },
            ),
          ),
          if (_isSaving) const CircularProgressIndicator(),
          if (_ticketStatus == TicketStatus.needReWork &&
              !_isEditing &&
              !_isSaving)
            TextButton.icon(
              onPressed: () {
                _oldValue = _controller.text;
                setState(() {
                  _isEditing = true;
                });
                if (_focusNode.canRequestFocus) _focusNode.requestFocus();
              },
              label: const Text('Edit'),
              icon: Icon(Icons.edit_outlined),
            ),
          if (_isEditing && !_isSaving) ...[
            TextButton.icon(
              onPressed: () {
                _saveChanges();
              },
              label: const Text('Save'),
              icon: Icon(Icons.save_outlined),
            ),
            TextButton.icon(
              onPressed: () {
                _controller.text = _oldValue;
                setState(() {
                  _validate = false;
                  _isEditing = false;
                });
              },
              label: const Text('Cancel'),
              icon: Icon(Icons.edit_off_outlined),
            ),
          ],
        ],
      ),
    );
  }

  void _saveChanges() async {
    if (_controller.text == _initialDescription) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    if (_controller.text.trim().isEmpty) {
      setState(() {
        _validate = true;
      });
      return;
    }
    if (_validate) {
      setState(() {
        _validate = false;
      });
    }
    try {
      await DataService.updateTicketDescription(
        _ticketId,
        _controller.text.trim(),
      );
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to update description');
      }
    } finally {
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    }
  }
}
