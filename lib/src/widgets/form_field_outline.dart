import 'package:flutter/material.dart';

class FormFieldOutline extends StatelessWidget {
  const FormFieldOutline({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        child
      ],
    );
  }
}
