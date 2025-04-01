import 'package:flutter/material.dart';

import 'config/themes/theme_config.dart';
import 'modules/screens/auth/auth_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morph Accountant',
      theme: themeConfig,
      home: const AuthPage(),
    );
  }
}
