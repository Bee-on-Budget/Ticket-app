// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:ticket_app/src/widgets/form_field_outline.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   String errorMessage = '';
//
//   Future<void> _login() async {
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, '/home');
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             SizedBox(height: 50),
//             Text(
//               "Login Screen",
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             SizedBox(height: 30),
//             FormFieldOutline(
//               controller: _emailController,
//               label: "Email",
//             ),
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _login,
//               child: Text('Login'),
//             ),
//             SizedBox(height: 16),
//             if (errorMessage.isNotEmpty)
//               Text(
//                 errorMessage,
//                 style: TextStyle(color: Colors.red),
//               ),
//             SizedBox(height: 16),
//             TextButton(
//               onPressed: () =>
//                   Navigator.pushReplacementNamed(context, '/register'),
//               child: Text('Don\'t have an account? Register here'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    try {
      // Masuk menggunakan email dan password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    // Tampilkan dialog dengan pesan error
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  String _errorMessage = "";

  void validateEmail(String val) {
    if (val.isEmpty) {
      // Validasi jika email kosong
      setState(() {
        _errorMessage = "Email tidak boleh kosong";
      });
    } else if (!EmailValidator.validate(val, true)) {
      // Validasi jika email tidak valid
      setState(() {
        _errorMessage = "Alamat Email tidak valid";
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
                                      validateEmail(emailController.text);
                                    }),
                                    controller: emailController,
                                    hintText: "masukkan email anda",
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
                                    controller: passwordController,
                                    hintText: "**************",
                                    obscureText: true,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SubmitButton(
                                    onPressed: signUserIn,
                                    buttonText: 'Submit',
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(35, 0, 0, 0),
                                    child: Row(
                                      children: [
                                        Text("Belum punya akun?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Color(0XFF8D8D8D),
                                            )),
                                        TextButton(
                                          child: Text(
                                            "Daftar",
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
