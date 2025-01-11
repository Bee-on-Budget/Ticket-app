import 'package:flutter/material.dart';

class FormFieldOutline extends StatelessWidget {
  const FormFieldOutline({
    super.key,
    required String label,
    required TextEditingController controller,
  })  : _label = label,
        _controller = controller;

  final String _label;
  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: OutlineInputBorder(),
          labelText: _label),
    );
  }
}
