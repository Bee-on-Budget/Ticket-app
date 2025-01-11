import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/form_field_outline.dart';
import '../../widgets/submit_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = "";

  Future<void> _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
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
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.green,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(0, 400, 0, 0),
          shrinkWrap: true,
          reverse: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 535,
                      width: double.infinity,
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
                              "Register",
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
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 0, 0),
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
                                    onPressed: _register,
                                    buttonText: 'Register',
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(35, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        Text("Already have an account?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Color(0XFF8D8D8D),
                                            )),
                                        TextButton(
                                          child: Text(
                                            "Login",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Color(0XFF44564A),
                                            ),
                                          ),
                                          onPressed: () =>
                                              Navigator.pushReplacementNamed(
                                                  context, '/login'),
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
                    Transform.translate(
                      offset: const Offset(0, -253),
                      child: Image.asset(
                        'assets/Images/plants2.png',
                        scale: 1.5,
                        width: double.infinity,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
