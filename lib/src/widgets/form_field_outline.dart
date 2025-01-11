// import 'package:flutter/material.dart';
//
// class FormFieldOutline extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final bool obscureText;
//
//   const FormFieldOutline({
//     required this.label,
//     required this.controller,
//     this.obscureText = false,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }
// }

// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormFieldOutline extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon prefixIcon;
  final Function()? onChanged;

  const FormFieldOutline(
      {super.key,
        required this.controller,
        required this.hintText,
        required this.obscureText,
        required this.prefixIcon,
        this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Color(0xFF4F4F4F),
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Color(0xFFF0F3F1),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: Color(0xFF8D8D8D),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: prefixIcon,
        prefixIconColor: Color(0xFF4F4F4F),
        filled: true,
      ),
    );
  }
}