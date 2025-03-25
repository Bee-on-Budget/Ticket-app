import 'package:flutter/material.dart';

class FormFieldOutline extends StatelessWidget {
  const FormFieldOutline({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  final String label;
  final Widget child;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(text: label, children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ]),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        child
      ],
    );
  }
}
