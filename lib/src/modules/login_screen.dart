import 'package:flutter/material.dart';
import 'package:ticket_app/src/widgets/form_field_outline.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 3,
        children: [
          SizedBox(height: 50),
          Text(
            "Login Screen",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 30),
          FormFieldOutline(
            label: "Email",
            controller: _emailController,
          ),
        ],
      ),
    );
  }
}
