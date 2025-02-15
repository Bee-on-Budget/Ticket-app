import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownOutline extends StatefulWidget {
  const DropdownOutline({
    super.key,
    required this.items,
    required this.value,
  });

  final List<String> items;
  final String value;

  @override
  State<DropdownOutline> createState() => _DropdownOutlineState();
}

class _DropdownOutlineState extends State<DropdownOutline> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: InputDecoration(
        fillColor: const Color(0xFFF0F3F1),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        hintStyle: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF8D8D8D),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
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
        filled: true,
      ),
      dropdownColor: const Color(0xFFF0F3F1),
      items: widget.items
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _status = value!),
    );
  }
}
