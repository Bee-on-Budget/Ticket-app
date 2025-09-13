import 'package:flutter/material.dart';

class LogoHalfBorder extends StatelessWidget {
  const LogoHalfBorder({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: _HalfCircleClipper(),
      child: Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: const Color(0XFFC5BFAE),
          borderRadius: BorderRadius.circular((width) / 2),
        ),
      ),
    );
  }
}

class _HalfCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      0,
      size.width,
      size.height / 2, // Only shows the top half
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
