import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../forget_password_screen.dart';
import '../../../utils/ui/login_form.dart';

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
            child: Column(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forget your password?",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color(0XFF8D8D8D),
                        ),
                      ),
                      TextButton(
                        child: Text(
                          "Reset",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Color(0XFF44564A),
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgetPasswordScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
