import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormFieldOutline extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldSetter<String>? onSave;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final int maxLines;

  const FormFieldOutline({
    super.key,
    this.controller,
    this.onSave,
    required this.hintText,
    this.obscureText = false,
    required this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<FormFieldOutline> createState() => _FormFieldOutlineState();
}

class _FormFieldOutlineState extends State<FormFieldOutline> {
  late bool isObscure;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onSaved: widget.onSave,
      obscureText: isObscure,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field can't be empty";
        }
        return null;
      },
      cursorColor: Color(0xFF4F4F4F),
      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: Color(0xFFF0F3F1),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: Color(0xFF8D8D8D),
        ),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.blueGrey,
              width: 1,
            )),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFF3D4B3F),
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(widget.prefixIcon),
        prefixIconColor: Color(0xFF4F4F4F),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: _changeObscure,
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        filled: true,
      ),
    );
  }

  void _changeObscure() {
    setState(() {
      isObscure = !isObscure;
    });
  }
}
