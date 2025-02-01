import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticket_app/src/service/auth_exception_handler.dart';
import 'package:ticket_app/src/service/auth_service.dart';

import '../../widgets/form_field_outline.dart';
import '../../widgets/submit_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm(this.setLoading, {super.key});

  final void Function(bool) setLoading;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final _authService = AuthService();
  late String _email;
  late String _password;

  String _errorMessage = "";

  Future<void> _login() async {
    setState(() {
      _errorMessage = "";
    });
    widget.setLoading(true);
    if (_formKey.currentState!.validate()) {
      await Future.delayed(Duration(seconds: 1));
      _formKey.currentState!.save();

      final status = await _authService.login(
        email: _email,
        password: _password,
      );
      if (status == AuthStatus.successful) {
        if (mounted) {
          // Navigator.of(context).pushNamedAndRemoveUntil(newRouteName, predicate);
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            ModalRoute.withName('/'),
          );
        }
      } else {
        widget.setLoading(false);
        final String error = AuthExceptionHandler.generateErrorMessage(status);
        setState(() {
          _errorMessage = error;
        });
      }
    }
    widget.setLoading(false);
  }

  // void _validateEmail(String val) {
  //   if (val.isEmpty) {
  //     setState(() {
  //       _errorMessage = "Email cannot be empty";
  //     });
  //   } else if (!EmailValidator.validate(val, true)) {
  //     setState(() {
  //       _errorMessage = "Invalid email address";
  //     });
  //   } else {
  //     setState(() {
  //       _errorMessage = "";
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Color(0xFF8D8D8D),
                ),
              ),
              const SizedBox(height: 10),
              FormFieldOutline(
                onSave: (email) {
                  _email = email!.trim();
                },
                hintText: "Enter your email",
                prefixIcon: Icons.mail_outline,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  0,
                  0,
                  0,
                ),
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Password",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Color(0XFF8D8D8D),
                ),
              ),
              const SizedBox(height: 10),
              FormFieldOutline(
                onSave: (password) {
                  _password = password!;
                },
                hintText: "**************",
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SubmitButton(
                  onPressed: _login,
                  buttonText: 'Submit',
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
