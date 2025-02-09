import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Color(0xFF8D8D8D),
          ),
        ),
        child
      ],
    );
  }
}
