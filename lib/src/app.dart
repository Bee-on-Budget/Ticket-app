import 'package:flutter/material.dart';

import 'modules/screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ticket App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Ticket App"),
        ),
        body: LoginScreen(),
      ),
    );
  }
}
