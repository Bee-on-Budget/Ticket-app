import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_app/src/modules/screens/register_screen.dart';
import '../../widgets/form_field_outline.dart';
import '../../widgets/submit_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = "";

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void validateEmail(String val) {
    if (val.isEmpty) {
      setState(() {
        _errorMessage = "Email cannot be empty";
      });
    } else if (!EmailValidator.validate(val, true)) {
      setState(() {
        _errorMessage = "Invalid email address";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = min(MediaQuery.of(context).size.width * 0.3, 250);
    final double height = max(530, MediaQuery.of(context).size.height * 0.75);
    // TODO:: add keyboard_dismisser
    // TODO:: add form for submit
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFF3D4B3F),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.only(top: 75),
                height: height,
                // width: double.infinity,
                // constraints: BoxConstraints.,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
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
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Color(0xFF8D8D8D),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FormFieldOutline(
                              onChanged: (() {
                                validateEmail(_emailController.text);
                              }),
                              controller: _emailController,
                              hintText: "Enter your email",
                              obscureText: false,
                              prefixIcon: const Icon(Icons.mail_outline),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Password",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Color(0XFF8D8D8D),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FormFieldOutline(
                              controller: _passwordController,
                              hintText: "**************",
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SubmitButton(
                              onPressed: _login,
                              buttonText: 'Submit',
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                              child: Row(
                                children: [
                                  Text("Don't have an account?",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Color(0XFF8D8D8D),
                                      )),
                                  TextButton(
                                    child: Text(
                                      "Register",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Color(0XFF44564A),
                                      ),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RegistrationScreen(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: height - (width * 0.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF3D4B3F),
                  borderRadius: BorderRadius.circular(360),
                ),
                child: Image.asset(
                  'assets/images/logo-nobg.png',
                  width: width,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
