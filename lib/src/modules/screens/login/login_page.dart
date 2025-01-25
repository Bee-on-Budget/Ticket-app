import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import './login_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF3D4B3F),
        body: Stack(
          alignment: Alignment.center,
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Spacer(),
                            LoginScreen(setLoading),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading) ...[
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0x33888888),
              ),
              CircularProgressIndicator(),
            ]
          ],
        ),
      ),
    );
  }
}
