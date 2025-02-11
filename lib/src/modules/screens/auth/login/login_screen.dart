import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/ui/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen(
      this.setLoading, {
        super.key,
      });

  final void Function(bool) setLoading;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double width = min(screenWidth * 0.3, 200);

    return Padding(
      padding: EdgeInsets.only(top: width / 2),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: (width / 2) + 2,
              right: 20,
              left: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column( // this where you should make the swipe
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Log In",
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F4F4F),
                  ),
                ),
                LoginForm(setLoading),
              ],
            ),
          ),
          Positioned(
            top: -(width / 2),
            child: Image.asset(
              'assets/images/logo-round.png',
              width: width,
            ),
          ),
        ],
      ),
    );
  }
}