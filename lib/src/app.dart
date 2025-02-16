import 'package:flutter/material.dart';

import 'config/themes/theme_config.dart';
import 'modules/screens/auth/login/login_page.dart';
import 'modules/screens/auth/auth_page.dart';
import 'modules/screens/home/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticket App',
      initialRoute: '/',
      theme: themeConfig,
      routes: {
        '/': (context) => const AuthPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
