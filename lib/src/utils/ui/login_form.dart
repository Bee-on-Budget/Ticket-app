import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../service/auth_exception_handler.dart';
import '../../service/auth_service.dart';
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
  final TextEditingController _emailController = TextEditingController();

  final _authService = AuthService();
  String _email = '';
  String _password = '';

  bool _isObscure = true;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

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
                label: "Email",
                child: TextFormField(
                  forceErrorText: _errorMessage,
                  onSaved: (email) => _email = email!,
                  controller: _emailController,
                  validator: _emailValidator,
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              FormFieldOutline(
                label: "Password",
                child: TextFormField(
                  onSaved: (password) => _password = password!,
                  onFieldSubmitted: (string) {
                    _login();
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
              Container(
                padding: EdgeInsets.only(top: 10),
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
    setState(() {
      _errorMessage = null;
    });
    if (_formKey.currentState!.validate()) {
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
