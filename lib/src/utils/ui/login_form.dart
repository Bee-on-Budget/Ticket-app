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
            spacing: 10,
            children: [
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
                label: "Email",
                child: TextFormField(
                  forceErrorText: _errorMessage,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (_) => _passwordFocus.nextFocus(),
                  onSaved: (email) {
                    _email = email ?? '';
                  },
                  controller: _emailController,
                  validator: _emailValidator,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              FormFieldOutline(
                label: "Password",
                child: TextFormField(
                  onSaved: (password) {
                    _password = password ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field can't be empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "**************",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: _changeObscure,
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _isObscure,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: SubmitButton(
                  onPressed: _login,
                  buttonText: 'Submit',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35),
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
                      onPressed: _resetPassword,
                      child: Text(
                        "Reset",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color(0XFF44564A),
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
    );
  }

  Future<void> _login() async {
    widget.setLoading(true);
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      _formKey.currentState!.save();
      final AuthStatus status = await _authService.loginViaEmail(
        email: _email,
        password: _password,
      );
      if (status == AuthStatus.successful) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        widget.setLoading(false);
        setState(() {
          _errorMessage = AuthExceptionHandler.generateErrorMessage(status);
        });
      }
    }
    widget.setLoading(false);
  }

  String? _emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return "Field can't be empty";
    }
    if (!EmailValidator.validate(email, true)) {
      return "Enter a valid email";
    }
    return null;
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Enter your email address";
      });
      return;
    }
    if (!EmailValidator.validate(email, true)) {
      setState(() {
        _errorMessage = "Enter a valid email";
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    final AuthStatus status = await _authService.resetPassword(email: email);
    if (status == AuthStatus.successful) {
      _emailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Reset message has been sent, please check your email.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            duration: const Duration(seconds: 10),
            showCloseIcon: true,
          ),
        );
      }
    } else {
      if (mounted) {
        final String error = AuthExceptionHandler.generateErrorMessage(status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            duration: const Duration(seconds: 10),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  void _changeObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }
}
