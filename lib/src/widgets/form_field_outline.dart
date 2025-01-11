import 'package:flutter/material.dart';

class FormFieldOutline extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const FormFieldOutline({
    required this.label,
    required this.controller,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
